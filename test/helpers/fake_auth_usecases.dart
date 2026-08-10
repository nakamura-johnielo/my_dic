// Helper extensions for creating fake UseCases for testing.

import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/port/app_auth.dart';
import 'package:my_dic/features/auth/port/auth_commands.dart';
import 'package:my_dic/features/auth/port/auth_readers.dart';

import 'test_helpers.dart';

/// Fake SignInInteractor for testing
class FakeSignInInteractor implements SignInPort {
  final Result<AppAuth>? _executeResult;

  int callCount = 0;
  String? lastEmail;
  String? lastPassword;

  FakeSignInInteractor({Result<AppAuth>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<AppAuth>> signIn(String email, String password) async {
    callCount++;
    lastEmail = email;
    lastPassword = password;

    return _executeResult ?? Result.success(createTestAuth());
  }

}

/// Fake SignUpInteractor for testing
class FakeSignUpInteractor implements SignUpPort {
  final Result<AppAuth>? _executeResult;

  int callCount = 0;

  FakeSignUpInteractor({Result<AppAuth>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<AppAuth>> signUp(String email, String password) async {
    callCount++;
    return _executeResult ?? Result.success(createTestAuth(isVerified: false));
  }

}

/// Fake VerifyEmailInteractor for testing
class FakeVerifyEmailInteractor implements SendVerificationEmailPort {
  final Result<void>? _executeResult;

  int callCount = 0;

  FakeVerifyEmailInteractor({Result<void>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<void>> sendVerificationEmail() async {
    callCount++;
    return _executeResult ?? const Result.success(null);
  }

}

/// Fake SignOutInteractor for testing
class FakeSignOutInteractor implements SignOutPort {
  final Result<void>? _executeResult;

  int callCount = 0;

  FakeSignOutInteractor({Result<void>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<void>> signOut() async {
    callCount++;
    return _executeResult ?? const Result.success(null);
  }

}

class FakeReloadCurrentAuthInteractor implements ReloadCurrentAuthPort {
  Result<AppAuth> executeResult;
  int callCount = 0;

  FakeReloadCurrentAuthInteractor({Result<AppAuth>? executeResult})
      : executeResult = executeResult ?? Result.success(createTestAuth());

  @override
  Future<Result<AppAuth>> reloadCurrentAuth() async {
    callCount++;
    return executeResult;
  }

}
