import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/app/workflows/session_lifecycle/auth_lifecycle_controller.dart';
import 'package:my_dic/app/workflows/session_lifecycle/auth_lifecycle_provider.dart';
import 'package:my_dic/app/workflows/session_lifecycle/user_profile_composition.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user_profile/port/composition.dart';
import 'package:my_dic/features/user_profile/port/guest_migration.dart';
import 'package:my_dic/features/user_profile/port/live_user_profile.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/user_profile/internal/application/usecase/user_usecases.dart';

import '../../../helpers/fake_auth_usecases.dart';
import '../../../helpers/fake_user_usecases.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('appSessionProvider', () {
    test('cold start is Initializing', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      expect(container.read(appSessionProvider), isA<AppSessionInitializing>());
    });

    test('signed out has no accountId', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container
          .read(authLifecycleProvider.notifier)
          .handleAuthStateChange(null);

      final session = container.read(appSessionProvider);
      expect(session, isA<AppSessionSignedOut>());
      expect(session.accountIdOrNull, isNull);
    });

    test('email-unverified identity is not Ready and has no accountId',
        () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container
          .read(authLifecycleProvider.notifier)
          .handleAuthStateChange(createTestAuth(isVerified: false));

      final session = container.read(appSessionProvider);
      expect(session, isA<AppSessionEmailUnverified>());
      expect(session.accountIdOrNull, isNull);
    });

    test('profile provisioning failure is a Failure, not SignedOut', () async {
      final ensure = FakeEnsureUserExistsInteractor(
        executeResult: Result.failure(NotFoundError(message: 'no profile')),
      );
      final container = _makeContainer(ensure: ensure);
      addTearDown(container.dispose);

      await container
          .read(authLifecycleProvider.notifier)
          .handleAuthStateChange(createTestAuth(isVerified: true));

      expect(container.read(appSessionProvider), isA<AppSessionFailure>());
    });

    test('ready session exposes accountId through CurrentSession', () async {
      final ensure = FakeEnsureUserExistsInteractor(
        executeResult: Result.success(AppUser(deviceId: 'device-1')),
      );
      final container = _makeContainer(ensure: ensure);
      addTearDown(container.dispose);

      final auth = createTestAuth(isVerified: true);
      await container
          .read(authLifecycleProvider.notifier)
          .handleAuthStateChange(auth);
      container.read(appSessionProvider);
      await _settleProfile();

      final session = container.read(appSessionProvider);
      expect(session, isA<AppSessionReady>());
      expect(session.accountIdOrNull, auth.accountId);

      final currentSession = container.read(currentSessionProvider);
      expect(currentSession.accountIdOrNull, auth.accountId);
      expect(currentSession.requireAccountId(), auth.accountId);
    });

    test(
        'sign-out after ready clears accountId and does not keep the prior profile',
        () async {
      final ensure = FakeEnsureUserExistsInteractor(
        executeResult: Result.success(AppUser(deviceId: 'device-1')),
      );
      final container = _makeContainer(ensure: ensure);
      addTearDown(container.dispose);

      await container
          .read(authLifecycleProvider.notifier)
          .handleAuthStateChange(createTestAuth(isVerified: true));
      container.read(appSessionProvider);
      await _settleProfile();
      expect(container.read(appSessionProvider), isA<AppSessionReady>());

      await container
          .read(authLifecycleProvider.notifier)
          .handleAuthStateChange(null);

      final session = container.read(appSessionProvider);
      expect(session, isA<AppSessionSignedOut>());
      expect(session.accountIdOrNull, isNull);
      expect(container.read(currentSessionProvider).accountIdOrNull, isNull);
    });

    test('ready profile follows the account-scoped Drift stream', () async {
      final profiles = StreamController<AppUser?>();
      addTearDown(profiles.close);
      final container = _makeContainer(
        ensure: FakeEnsureUserExistsInteractor(
          executeResult: Result.success(
            AppUser(
              deviceId: 'device-1',
              email: 'baseline@example.com',
              username: 'Remote Baseline',
            ),
          ),
        ),
        profileStream: profiles.stream,
      );
      addTearDown(container.dispose);
      final subscription = container.listen(appSessionProvider, (_, __) {});
      addTearDown(subscription.close);

      final auth = createTestAuth(isVerified: true);
      await container
          .read(authLifecycleProvider.notifier)
          .handleAuthStateChange(auth);
      expect(
          container.read(appSessionProvider), isA<AppSessionLoadingProfile>());

      profiles.add(_profile('Local Edit'));
      await _settleProfile();
      var session = container.read(appSessionProvider) as AppSessionReady;
      expect(session.profile.username, 'Local Edit');
      expect(session.profile.deviceId, 'device-1');
      expect(session.identity.email, auth.email);

      profiles.add(_profile('Pulled Edit'));
      await _settleProfile();
      session = container.read(appSessionProvider) as AppSessionReady;
      expect(session.profile.username, 'Pulled Edit');
    });

    test('profile stream failure becomes an account-scoped session failure',
        () async {
      final profiles = StreamController<AppUser?>();
      addTearDown(profiles.close);
      final container = _makeContainer(
        ensure: FakeEnsureUserExistsInteractor(
          executeResult: Result.success(AppUser(deviceId: 'device-1')),
        ),
        profileStream: profiles.stream,
      );
      addTearDown(container.dispose);
      final subscription = container.listen(appSessionProvider, (_, __) {});
      addTearDown(subscription.close);

      final auth = createTestAuth(isVerified: true);
      await container
          .read(authLifecycleProvider.notifier)
          .handleAuthStateChange(auth);
      profiles.addError(StateError('database unavailable'));
      await _settleProfile();

      final session = container.read(appSessionProvider);
      expect(session, isA<AppSessionFailure>());
      expect(
          (session as AppSessionFailure).identity?.accountId, auth.accountId);
    });

    test('CurrentSession.requireAccountId throws without a session', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(currentSessionProvider).requireAccountId(),
        throwsA(isA<SessionRequiresAccountError>()),
      );
    });
  });
}

ProviderContainer _makeContainer({
  IEnsureUserExistsUseCase? ensure,
  Stream<AppUser?>? profileStream,
}) {
  final container = ProviderContainer(
    overrides: [
      authLifecycleProvider.overrideWith((ref) {
        return AuthLifecycleController(
          signIn: FakeSignInInteractor(),
          signUp: FakeSignUpInteractor(),
          signOut: FakeSignOutInteractor(),
          sendVerificationEmail: FakeVerifyEmailInteractor(),
          reloadCurrentAuth: FakeReloadCurrentAuthInteractor(),
          ensureUserExists: ensure ?? FakeEnsureUserExistsInteractor(),
        );
      }),
      userProfilePortsProvider.overrideWithValue(
        UserProfilePorts(
          ensureUserProfile: ensure ?? FakeEnsureUserExistsInteractor(),
          liveUserProfile: _LiveProfilePort(
            profileStream ?? Stream.value(_profile('Test User')),
          ),
          guestMigration: _NoopGuestMigrationPort(),
          updateUserProfile: FakeUpdateUserInteractor(),
        ),
      ),
    ],
  );
  return container;
}

AppUser _profile(String username) => AppUser(username: username);

class _LiveProfilePort implements LiveUserProfilePort {
  const _LiveProfilePort(this._profiles);

  final Stream<AppUser?> _profiles;

  @override
  Stream<AppUser?> watchProfile(String accountId) => _profiles;
}

class _NoopGuestMigrationPort implements UserProfileGuestMigrationPort {
  @override
  Future<bool> hasGuestProfile() async => false;

  @override
  Future<void> migrateGuestProfile({
    required String accountId,
    required String migrationId,
    required OutboxWriter outboxWriter,
    required DateTime Function() clock,
  }) async {}
}

Future<void> _settleProfile() =>
    Future<void>.delayed(const Duration(milliseconds: 10));
