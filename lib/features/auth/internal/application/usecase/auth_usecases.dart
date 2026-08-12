import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/internal/domain/repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/port/app_auth.dart';
import 'package:my_dic/features/auth/port/auth_commands.dart';
import 'package:my_dic/features/auth/port/auth_readers.dart';

abstract interface class IObserveAuthStateUseCase
    implements ObserveAuthStatePort {
  Stream<AppAuth?> execute();

  @override
  Stream<AppAuth?> observeAuthState() => execute();
}

abstract interface class IReloadCurrentAuthUseCase
    implements ReloadCurrentAuthPort {
  Future<Result<AppAuth>> execute();

  @override
  Future<Result<AppAuth>> reloadCurrentAuth() => execute();
}

abstract interface class IResetEmailPasswordUseCase {
  Future<Result<void>> execute(String email);
}

abstract interface class ISignOutUseCase implements SignOutPort {
  Future<Result<void>> execute();

  @override
  Future<Result<void>> signOut() => execute();
}

abstract interface class ISignUpUseCase implements SignUpPort {
  Future<Result<AppAuth>> execute(String email, String password);

  @override
  Future<Result<AppAuth>> signUp(String email, String password) =>
      execute(email, password);
}

abstract interface class IVerifyEmailUseCase
    implements SendVerificationEmailPort {
  Future<Result<void>> execute();

  @override
  Future<Result<void>> sendVerificationEmail() => execute();
}

class ObserveAuthStateInteractor implements IObserveAuthStateUseCase {
  ObserveAuthStateInteractor(this._repository);
  final IAuthRepository _repository;
  @override
  Stream<AppAuth?> execute() => _repository.observeAuthState();

  @override
  Stream<AppAuth?> observeAuthState() => execute();
}

class ReloadCurrentAuthInteractor implements IReloadCurrentAuthUseCase {
  ReloadCurrentAuthInteractor(this._repository);
  final IAuthRepository _repository;
  @override
  Future<Result<AppAuth>> execute() => _repository.reloadCurrentAuth();

  @override
  Future<Result<AppAuth>> reloadCurrentAuth() => execute();
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

  @override
  Future<Result<void>> signOut() => execute();
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

  @override
  Future<Result<AppAuth>> signUp(String email, String password) =>
      execute(email, password);
}

class VerifyEmailInteractor implements IVerifyEmailUseCase {
  VerifyEmailInteractor(this._repository);
  final IAuthRepository _repository;
  @override
  Future<Result<void>> execute() => _repository.sendEmailVerification();

  @override
  Future<Result<void>> sendVerificationEmail() => execute();
}
