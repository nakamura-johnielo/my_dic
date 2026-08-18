// Helper extensions for creating fake UseCases for testing.

import 'package:my_dic/features/auth/port/auth.dart';

import 'test_helpers.dart';

final class FakeAuthQueryService implements AuthQueryPort {
  const FakeAuthQueryService(this.reload);
  final FakeReloadCurrentAuthInteractor reload;

  @override
  Stream<AuthIdentity?> observeAuthState() => const Stream.empty();

  @override
  Future<Result<AuthIdentity>> reloadCurrentAuth() =>
      reload.reloadCurrentAuth();
}

final class FakeAuthCommandService implements AuthCommandPort {
  const FakeAuthCommandService({
    required this.signInFake,
    required this.signUpFake,
    required this.signOutFake,
    required this.verifyFake,
  });

  final FakeSignInInteractor signInFake;
  final FakeSignUpInteractor signUpFake;
  final FakeSignOutInteractor signOutFake;
  final FakeVerifyEmailInteractor verifyFake;

  @override
  Future<Result<AuthIdentity>> signIn(SignInCommand command) =>
      signInFake.signIn(command);
  @override
  Future<Result<AuthIdentity>> signUp(SignUpCommand command) =>
      signUpFake.signUp(command);
  @override
  Future<Result<void>> signOut() => signOutFake.signOut();
  @override
  Future<Result<void>> sendVerificationEmail() =>
      verifyFake.sendVerificationEmail();
  @override
  Future<Result<void>> resetPassword(ResetPasswordCommand command) =>
      throw UnsupportedError('Not used by lifecycle tests.');
}

/// Fake SignInInteractor for testing
class FakeSignInInteractor implements AuthCommandPort {
  final Result<AuthIdentity>? _executeResult;

  int callCount = 0;
  String? lastEmail;
  String? lastPassword;

  FakeSignInInteractor({Result<AuthIdentity>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<AuthIdentity>> signIn(SignInCommand command) async {
    callCount++;
    lastEmail = command.email;
    lastPassword = command.password;

    return _executeResult ?? Result.success(createTestAuth());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake SignUpInteractor for testing
class FakeSignUpInteractor implements AuthCommandPort {
  final Result<AuthIdentity>? _executeResult;

  int callCount = 0;

  FakeSignUpInteractor({Result<AuthIdentity>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<AuthIdentity>> signUp(SignUpCommand command) async {
    callCount++;
    return _executeResult ?? Result.success(createTestAuth(isVerified: false));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake VerifyEmailInteractor for testing
class FakeVerifyEmailInteractor implements AuthCommandPort {
  final Result<void>? _executeResult;

  int callCount = 0;

  FakeVerifyEmailInteractor({Result<void>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<void>> sendVerificationEmail() async {
    callCount++;
    return _executeResult ?? const Result.success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake SignOutInteractor for testing
class FakeSignOutInteractor implements AuthCommandPort {
  final Result<void>? _executeResult;

  int callCount = 0;

  FakeSignOutInteractor({Result<void>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<void>> signOut() async {
    callCount++;
    return _executeResult ?? const Result.success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeReloadCurrentAuthInteractor implements AuthQueryPort {
  Result<AuthIdentity> executeResult;
  int callCount = 0;

  FakeReloadCurrentAuthInteractor({Result<AuthIdentity>? executeResult})
      : executeResult = executeResult ?? Result.success(createTestAuth());

  @override
  Future<Result<AuthIdentity>> reloadCurrentAuth() async {
    callCount++;
    return executeResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
