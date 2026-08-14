import 'package:my_dic/core/shared/utils/result.dart';

import 'model/auth_identity.dart';

/// Credentials submitted to the existing sign-in validation workflow.
final class SignInCommand {
  const SignInCommand({required this.email, required this.password});

  final String email;
  final String password;
}

/// Credentials submitted to the existing account-creation workflow.
final class SignUpCommand {
  const SignUpCommand({required this.email, required this.password});

  final String email;
  final String password;
}

final class ResetPasswordCommand {
  const ResetPasswordCommand({required this.email});

  final String email;
}

/// Auth-owned state-changing capabilities.
abstract interface class AuthCommandPort {
  Future<Result<AuthIdentity>> signIn(SignInCommand command);
  Future<Result<AuthIdentity>> signUp(SignUpCommand command);
  Future<Result<void>> signOut();
  Future<Result<void>> sendVerificationEmail();
  Future<Result<void>> resetPassword(ResetPasswordCommand command);
}
