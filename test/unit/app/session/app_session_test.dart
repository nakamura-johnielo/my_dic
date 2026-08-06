import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_controller.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_provider.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_state.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/presentation/view_model/auth_store.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/usecase/i_ensure_user_exists_use_case.dart';
import 'package:my_dic/features/user/presentation/view_model/app_user_store.dart';

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

      container.read(authLifecycleProvider.notifier).handleAuthStateChange(null);

      final session = container.read(appSessionProvider);
      expect(session, isA<AppSessionSignedOut>());
      expect(session.accountIdOrNull, isNull);
    });

    test('email-unverified identity is not Ready and has no accountId', () async {
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
      expect(container.read(appSessionProvider), isA<AppSessionReady>());

      await container.read(authLifecycleProvider.notifier).handleAuthStateChange(null);

      final session = container.read(appSessionProvider);
      expect(session, isA<AppSessionSignedOut>());
      expect(session.accountIdOrNull, isNull);
      expect(container.read(currentSessionProvider).accountIdOrNull, isNull);
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

ProviderContainer _makeContainer({IEnsureUserExistsUseCase? ensure}) {
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
          authStore: AuthStoreNotifier(),
          userStore: AppUserStoreNotifier(),
        );
      }),
    ],
  );
  return container;
}
