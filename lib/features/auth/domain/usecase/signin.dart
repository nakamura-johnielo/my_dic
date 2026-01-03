import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/domain/usecase/i_sign_in_use_case.dart';

class SignInInteractor implements ISignInUseCase {
  final IAuthRepository _authRepository;
  SignInInteractor(this._authRepository);

  @override
  Future<Result<AppAuth>> execute(String email, String password) async {
    // Input validation
    final validationError = _validateInput(email, password);
    if (validationError != null) {
      return Result.failure(validationError);
    }

    // Execute sign in
    return await _authRepository.signInWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  ValidationError? _validateInput(String email, String password) {
    final errors = <String, List<String>>{};

    if (email.trim().isEmpty) {
      errors['email'] = ['メールアドレスを入力してください'];
    }

    if (password.isEmpty) {
      errors['password'] = ['パスワードを入力してください'];
    }

    if (errors.isNotEmpty) {
      return ValidationError(
        message: '入力内容に誤りがあります',
        fieldErrors: errors,
      );
    }

    return null;
  }
}
