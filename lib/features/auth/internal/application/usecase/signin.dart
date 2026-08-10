import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/internal/application/usecase/i_sign_in_use_case.dart';
import 'package:my_dic/features/auth/internal/domain/repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/port/app_auth.dart';

class SignInInteractor implements ISignInUseCase {
  SignInInteractor(this._repository);
  final IAuthRepository _repository;

  @override
  Future<Result<AppAuth>> execute(String email, String password) async {
    final errors = <String, List<String>>{};
    if (email.trim().isEmpty) errors['email'] = ['Email is required'];
    if (password.isEmpty) errors['password'] = ['Password is required'];
    if (errors.isNotEmpty) {
      return Result.failure(ValidationError(
        message: 'Invalid sign-in input',
        fieldErrors: errors,
      ));
    }
    return _repository.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<Result<AppAuth>> signIn(String email, String password) =>
      execute(email, password);
}
