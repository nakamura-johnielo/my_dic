/// Helper extensions for creating fake UseCases for testing

import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/usecase/i_sign_in_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_sign_out_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_sign_up_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_verify_email_use_case.dart';

import 'test_helpers.dart';

/// Fake SignInInteractor for testing
class FakeSignInInteractor implements ISignInUseCase {
  final Result<AppAuth>? _executeResult;

  int callCount = 0;
  String? lastEmail;
  String? lastPassword;

  FakeSignInInteractor({Result<AppAuth>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<AppAuth>> execute(String email, String password) async {
    callCount++;
    lastEmail = email;
    lastPassword = password;

    return _executeResult ?? Result.success(createTestAuth());
  }
}

/// Fake SignUpInteractor for testing
class FakeSignUpInteractor implements ISignUpUseCase {
  final Result<AppAuth>? _executeResult;

  int callCount = 0;

  FakeSignUpInteractor({Result<AppAuth>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<AppAuth>> execute(String email, String password) async {
    callCount++;
    return _executeResult ?? Result.success(createTestAuth(isVerified: false));
  }
}

/// Fake VerifyEmailInteractor for testing
class FakeVerifyEmailInteractor implements IVerifyEmailUseCase {
  final Result<void>? _executeResult;

  int callCount = 0;

  FakeVerifyEmailInteractor({Result<void>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<void>> execute() async {
    callCount++;
    return _executeResult ?? const Result.success(null);
  }
}

/// Fake SignOutInteractor for testing
class FakeSignOutInteractor implements ISignOutUseCase {
  final Result<void>? _executeResult;

  int callCount = 0;

  FakeSignOutInteractor({Result<void>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<void>> execute() async {
    callCount++;
    return _executeResult ?? const Result.success(null);
  }
}
