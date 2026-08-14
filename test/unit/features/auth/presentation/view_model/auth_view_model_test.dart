import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/auth_lifecycle_controller.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/auth_lifecycle_state.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

import '../../../../../helpers/fake_auth_usecases.dart';
import '../../../../../helpers/fake_user_profile_ports.dart';
import '../../../../../helpers/test_helpers.dart';

void main() {
  group('AuthLifecycleController', () {
    test('signUp sends verification email and remains unverified', () async {
      final signUp = FakeSignUpInteractor(
        executeResult: Result.success(createTestAuth(isVerified: false)),
      );
      final verify = FakeVerifyEmailInteractor();
      final ensure = FakeEnsureUserProfileCommands();
      final fixture = _Fixture(signUp: signUp, verify: verify, ensure: ensure);

      await fixture.controller.signUp('new@example.com', 'password123');

      expect(signUp.callCount, 1);
      expect(verify.callCount, 1);
      expect(ensure.callCount, 0);
      expect(
          fixture.controller.state.phase, AuthLifecyclePhase.emailUnverified);
      expect(fixture.controller.state.notice, isNotEmpty);
    });

    test(
        'verification delivery failure is retryable and is not reported as sent',
        () async {
      final verify = FakeVerifyEmailInteractor(
        executeResult: Result.failure(
          BusinessRuleError(message: 'verification delivery failed'),
        ),
      );
      final fixture = _Fixture(verify: verify);

      await fixture.controller.signUp('new@example.com', 'password123');

      expect(
        fixture.controller.state.phase,
        AuthLifecyclePhase.verificationEmailFailed,
      );
      expect(fixture.controller.state.notice, isNull);
      expect(fixture.controller.state.error?.message,
          'verification delivery failed');
      expect(fixture.controller.state.auth?.accountId, isNotEmpty);
    });

    test('unverified identity does not provision a profile', () async {
      final ensure = FakeEnsureUserProfileCommands();
      final fixture = _Fixture(ensure: ensure);

      await fixture.controller.handleAuthStateChange(
        createTestAuth(isVerified: false),
      );

      expect(ensure.callCount, 0);
      expect(
          fixture.controller.state.phase, AuthLifecyclePhase.emailUnverified);
      expect(fixture.controller.state.user, isNull);
    });

    test(
        'reload of a verified identity provisions the profile and becomes ready',
        () async {
      final reload = FakeReloadCurrentAuthInteractor(
        executeResult: Result.success(createTestAuth(isVerified: true)),
      );
      final ensure = FakeEnsureUserProfileCommands(
        executeResult: Result.success(
          AppUser(deviceId: 'device-1', email: 'test@example.com'),
        ),
      );
      final fixture = _Fixture(reload: reload, ensure: ensure);
      await fixture.controller.handleAuthStateChange(
        createTestAuth(isVerified: false),
      );

      await fixture.controller.checkEmailVerification();

      expect(reload.callCount, 1);
      expect(ensure.callCount, 1);
      expect(ensure.lastId, 'test-user-123');
      expect(ensure.lastEmail, 'test@example.com');
      expect(fixture.controller.state.phase, AuthLifecyclePhase.ready);
      expect(fixture.controller.state.user?.deviceId, 'device-1');
    });

    test('profile provisioning failure keeps auth and can be retried',
        () async {
      final ensure = _RetryableEnsureUser();
      final fixture = _Fixture(ensure: ensure);
      final auth = createTestAuth(isVerified: true);

      await fixture.controller.handleAuthStateChange(auth);
      expect(
        fixture.controller.state.phase,
        AuthLifecyclePhase.profileProvisioningFailed,
      );
      expect(fixture.controller.state.auth?.accountId, auth.accountId);

      ensure.shouldFail = false;
      await fixture.controller.retryProfileProvisioning();

      expect(ensure.callCount, 2);
      expect(fixture.controller.state.phase, AuthLifecyclePhase.ready);
    });

    test('signOut clears auth and user consistently', () async {
      final fixture = _Fixture();
      await fixture.controller.handleAuthStateChange(
        createTestAuth(isVerified: true),
      );
      expect(fixture.controller.state.phase, AuthLifecyclePhase.ready);

      await fixture.controller.signOut();

      expect(fixture.controller.state.phase, AuthLifecyclePhase.signedOut);
      expect(fixture.controller.state.auth, isNull);
      expect(fixture.controller.state.user, isNull);
    });

    test(
        'a stale profile result cannot restore the previous user after sign-out',
        () async {
      final ensure = _DeferredEnsureUser();
      final fixture = _Fixture(ensure: ensure);

      final provisioning = fixture.controller.handleAuthStateChange(
        createTestAuth(isVerified: true),
      );
      await fixture.controller.handleAuthStateChange(null);
      ensure.complete(
        AppUser(deviceId: 'old-device', email: 'old@example.com'),
      );
      await provisioning;

      expect(fixture.controller.state.phase, AuthLifecyclePhase.signedOut);
      expect(fixture.controller.state.auth, isNull);
      expect(fixture.controller.state.user, isNull);
    });
  });
}

class _Fixture {
  late final AuthLifecycleController controller;

  _Fixture({
    FakeSignUpInteractor? signUp,
    FakeVerifyEmailInteractor? verify,
    FakeReloadCurrentAuthInteractor? reload,
    UserProfileCommandPort? ensure,
  }) {
    final signUpFake = signUp ?? FakeSignUpInteractor();
    final verification = verify ?? FakeVerifyEmailInteractor();
    final reloadFake = reload ?? FakeReloadCurrentAuthInteractor();
    controller = AuthLifecycleController(
      query: FakeAuthQueryService(reloadFake),
      commands: FakeAuthCommandService(
        signInFake: FakeSignInInteractor(),
        signUpFake: signUpFake,
        signOutFake: FakeSignOutInteractor(),
        verifyFake: verification,
      ),
      userProfileCommands: ensure ?? FakeEnsureUserProfileCommands(),
    );
  }
}

class _RetryableEnsureUser implements UserProfileCommandPort {
  bool shouldFail = true;
  int callCount = 0;

  Future<Result<AppUser>> execute(String id, {String? email}) async {
    callCount++;
    if (shouldFail) {
      return Result.failure(NotFoundError(message: 'profile unavailable'));
    }
    return Result.success(AppUser(deviceId: 'device-1', email: email));
  }

  @override
  Future<Result<AppUser>> ensureUserProfile(String accountId,
          {String? email}) =>
      execute(accountId, email: email);

  @override
  Future<Result<void>> updateUser(AppUser user, String accountId) async =>
      const Result.success(null);
}

class _DeferredEnsureUser implements UserProfileCommandPort {
  final _completer = Completer<Result<AppUser>>();

  void complete(AppUser user) => _completer.complete(Result.success(user));

  Future<Result<AppUser>> execute(String id, {String? email}) =>
      _completer.future;

  @override
  Future<Result<AppUser>> ensureUserProfile(String accountId,
          {String? email}) =>
      execute(accountId, email: email);

  @override
  Future<Result<void>> updateUser(AppUser user, String accountId) async =>
      const Result.success(null);
}
