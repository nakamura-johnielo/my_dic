import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_controller.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_provider.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as db;
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/di/data_di.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/application/usecase/user_usecases.dart';

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
      final profiles = StreamController<db.UserProfile?>();
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

      profiles.add(_profile(auth.accountId, 'Local Edit'));
      await _settleProfile();
      var session = container.read(appSessionProvider) as AppSessionReady;
      expect(session.profile.username, 'Local Edit');
      expect(session.profile.deviceId, 'device-1');
      expect(session.identity.email, auth.email);

      profiles.add(_profile(auth.accountId, 'Pulled Edit'));
      await _settleProfile();
      session = container.read(appSessionProvider) as AppSessionReady;
      expect(session.profile.username, 'Pulled Edit');
    });

    test('profile stream failure becomes an account-scoped session failure',
        () async {
      final profiles = StreamController<db.UserProfile?>();
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
  Stream<db.UserProfile?>? profileStream,
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
      watchedUserProfileProvider.overrideWith(
        (ref, accountId) =>
            profileStream ?? Stream.value(_profile(accountId, 'Test User')),
      ),
    ],
  );
  return container;
}

db.UserProfile _profile(String accountId, String username) => db.UserProfile(
      accountId: accountId,
      payload: '{"username":"$username"}',
      localRevision: 1,
      remoteRevision: null,
      deletedAt: null,
      lastMutationId: null,
    );

Future<void> _settleProfile() =>
    Future<void>.delayed(const Duration(milliseconds: 10));
