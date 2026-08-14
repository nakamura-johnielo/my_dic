import 'command.dart';
import 'query.dart';

/// SDK-free identity facts returned by the application-owned Auth runtime.
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

/// SDK-free failure raised by the application-owned Auth runtime adapter.
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

/// Technical handle implemented by the application Firebase boundary.
///
/// Auth owns the interpretation of provider IDs and failure codes. The app
/// adapter owns only SDK calls and conversion into this SDK-free contract.
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

/// Completed Auth capabilities for one application scope.
final class AuthPorts {
  const AuthPorts({required this.query, required this.commands});

  final AuthQueryPort query;
  final AuthCommandPort commands;
}
