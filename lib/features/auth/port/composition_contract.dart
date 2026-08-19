import 'command.dart';
import 'query.dart';

/// アプリケーション所有のAuthランタイムが返す、SDKに依存しないID情報。
final class AuthRuntimeIdentity {
  const AuthRuntimeIdentity({
    required this.accountId,
    required this.emailVerified,
    this.email,
    this.credentialProviderId,
  });

  final String accountId;
  final String? email;
  final bool emailVerified;
  final String? credentialProviderId;
}

/// アプリケーション所有のAuthランタイムアダプターが発生させる、SDKに依存しない失敗。
final class AuthRuntimeFailure implements Exception {
  const AuthRuntimeFailure({
    required this.code,
    this.message,
    required this.originalError,
    required this.stackTrace,
  });

  final String code;
  final String? message;
  final Object originalError;
  final StackTrace stackTrace;
}

/// アプリケーションのFirebase境界が実装する技術的ハンドル。
///
/// プロバイダーIDと失敗コードの解釈はAuthが所有します。アプリアダプターはSDK呼び出しと、
/// このSDK非依存契約への変換だけを担当します。
abstract interface class AuthRuntimeGateway {
  Stream<AuthRuntimeIdentity?> observeAuthState();

  Future<AuthRuntimeIdentity?> createUserWithEmailAndPassword(
    String email,
    String password,
  );

  Future<AuthRuntimeIdentity?> signInWithEmailAndPassword(
    String email,
    String password,
  );

  Future<void> signOut();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordResetEmail({required String email});
  Future<AuthRuntimeIdentity?> getCurrentAuth();
  Future<AuthRuntimeIdentity?> reloadCurrentAuth();
}

/// 1つのアプリケーションスコープ用に完成したAuth機能群。
final class AuthPorts {
  const AuthPorts({required this.query, required this.commands});

  final AuthQueryPort query;
  final AuthCommandPort commands;
}
