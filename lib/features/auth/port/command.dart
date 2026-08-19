import 'package:my_dic/core/shared/utils/result.dart';

import 'model/auth_identity.dart';

/// 既存のサインイン検証ワークフローへ送信する認証情報。
final class SignInCommand {
  const SignInCommand({required this.email, required this.password});

  final String email;
  final String password;
}

/// 既存のアカウント作成ワークフローへ送信する認証情報。
final class SignUpCommand {
  const SignUpCommand({required this.email, required this.password});

  final String email;
  final String password;
}

final class ResetPasswordCommand {
  const ResetPasswordCommand({required this.email});

  final String email;
}

/// Authが所有する状態変更機能。
abstract interface class AuthCommandPort {
  Future<Result<AuthIdentity>> signIn(SignInCommand command);
  Future<Result<AuthIdentity>> signUp(SignUpCommand command);
  Future<Result<void>> signOut();
  Future<Result<void>> sendVerificationEmail();
  Future<Result<void>> resetPassword(ResetPasswordCommand command);
}
