import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';

abstract interface class IObserveAuthStateUseCase {
  Stream<AppAuth?> execute();
}

abstract interface class IReloadCurrentAuthUseCase {
  Future<Result<AppAuth>> execute();
}

abstract interface class IResetEmailPasswordUseCase {
  Future<Result<void>> execute(String email);
}

abstract interface class ISignOutUseCase {
  Future<Result<void>> execute();
}

abstract interface class ISignUpUseCase {
  Future<Result<AppAuth>> execute(String email, String password);
}

abstract interface class IVerifyEmailUseCase {
  Future<Result<void>> execute();
}

class ObserveAuthStateInteractor implements IObserveAuthStateUseCase {
  ObserveAuthStateInteractor(this._repository);
  final IAuthRepository _repository;
  @override
  Stream<AppAuth?> execute() => _repository.observeAuthState();
}

class ReloadCurrentAuthInteractor implements IReloadCurrentAuthUseCase {
  ReloadCurrentAuthInteractor(this._repository);
  final IAuthRepository _repository;
  @override
  Future<Result<AppAuth>> execute() => _repository.reloadCurrentAuth();
}

class ResetEmailPasswordInteractor implements IResetEmailPasswordUseCase {
  ResetEmailPasswordInteractor(this._repository);
  final IAuthRepository _repository;
  @override
  Future<Result<void>> execute(String email) =>
      _repository.sendPasswordResetEmail(email: email);
}

class SignOutInteractor implements ISignOutUseCase {
  SignOutInteractor(this._repository);
  final IAuthRepository _repository;
  @override
  Future<Result<void>> execute() => _repository.signOut();
}

class SignUpInteractor implements ISignUpUseCase {
  SignUpInteractor(this._repository);
  final IAuthRepository _repository;
  @override
  Future<Result<AppAuth>> execute(String email, String password) async {
    final errors = <String, List<String>>{};
    if (email.trim().isEmpty) {
      errors['email'] = ['Email is required'];
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email.trim())) {
      errors['email'] = ['Email is invalid'];
    }
    if (password.isEmpty) {
      errors['password'] = ['Password is required'];
    } else if (password.length < 6) {
      errors['password'] = ['Password must be at least 6 characters'];
    }
    if (errors.isNotEmpty) {
      return Result.failure(ValidationError(
        message: 'Invalid sign-up input',
        fieldErrors: errors,
      ));
    }
    return _repository.createUserWithEmailAndPassword(
        email: email.trim(), password: password.trim());
  }
}

class VerifyEmailInteractor implements IVerifyEmailUseCase {
  VerifyEmailInteractor(this._repository);
  final IAuthRepository _repository;
  @override
  Future<Result<void>> execute() => _repository.sendEmailVerification();
}
