import 'package:my_dic/features/auth/internal/domain/repository/auth_repository.dart';
import 'package:my_dic/features/auth/port/auth.dart';

/// Public Auth application facade over the characterized use cases.
final class AuthApplicationService implements AuthQueryPort, AuthCommandPort {
  const AuthApplicationService(this._repository);

  final IAuthRepository _repository;

  @override
  Stream<AuthIdentity?> observeAuthState() => _repository.observeAuthState();

  @override
  Future<Result<AuthIdentity>> reloadCurrentAuth() =>
      _repository.reloadCurrentAuth();

  @override
  Future<Result<AuthIdentity>> signIn(SignInCommand command) async {
    final errors = <String, List<String>>{};
    if (command.email.trim().isEmpty) errors['email'] = ['Email is required'];
    if (command.password.isEmpty) {
      errors['password'] = ['Password is required'];
    }
    if (errors.isNotEmpty) {
      return Result.failure(ValidationError(
        message: 'Invalid sign-in input',
        fieldErrors: errors,
      ));
    }
    return _repository.signInWithEmailAndPassword(
      email: command.email.trim(),
      password: command.password,
    );
  }

  @override
  Future<Result<AuthIdentity>> signUp(SignUpCommand command) async {
    final errors = <String, List<String>>{};
    if (command.email.trim().isEmpty) {
      errors['email'] = ['Email is required'];
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(command.email.trim())) {
      errors['email'] = ['Email is invalid'];
    }
    if (command.password.isEmpty) {
      errors['password'] = ['Password is required'];
    } else if (command.password.length < 6) {
      errors['password'] = ['Password must be at least 6 characters'];
    }
    if (errors.isNotEmpty) {
      return Result.failure(ValidationError(
        message: 'Invalid sign-up input',
        fieldErrors: errors,
      ));
    }
    return _repository.createUserWithEmailAndPassword(
      email: command.email.trim(),
      password: command.password.trim(),
    );
  }

  @override
  Future<Result<void>> signOut() => _repository.signOut();

  @override
  Future<Result<void>> sendVerificationEmail() =>
      _repository.sendEmailVerification();

  @override
  Future<Result<void>> resetPassword(ResetPasswordCommand command) =>
      _repository.sendPasswordResetEmail(email: command.email);
}
