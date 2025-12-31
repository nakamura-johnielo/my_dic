import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/domain/usecase/i_sign_up_use_case.dart';

class SignUpInteractor implements ISignUpUseCase {
  final IAuthRepository _authRepository;
  SignUpInteractor(this._authRepository);

  @override
  Future<Result<AppAuth>> execute(String email, String password) async {
    // Input validation
    final validationError = _validateInput(email, password);
    if (validationError != null) {
      return Result.failure(validationError);
    }

    // Execute sign up
    return await _authRepository.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  ValidationError? _validateInput(String email, String password) {
    final errors = <String, List<String>>{};

    if (email.trim().isEmpty) {
      errors['email'] = ['メールアドレスを入力してください'];
    } else if (!_isValidEmail(email.trim())) {
      errors['email'] = ['有効なメールアドレスを入力してください'];
    }

    if (password.isEmpty) {
      errors['password'] = ['パスワードを入力してください'];
    } else if (password.length < 6) {
      errors['password'] = ['パスワードは6文字以上にしてください'];
    }

    if (errors.isNotEmpty) {
      return ValidationError(
        message: '入力内容に誤りがあります',
        fieldErrors: errors,
      );
    }

    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
