// Fake Auth repository contract for tests.

import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/features/auth/internal/domain/repository/auth_repository.dart';
import 'package:my_dic/features/auth/port/auth.dart';

import 'test_helpers.dart';

class FakeAuthRepository implements AuthRepositoryContract {
  final Result<AuthIdentity>? _signInResult;
  final Result<AuthIdentity>? _signUpResult;
  final Result<void>? _signOutResult;
  final Result<void>? _verificationResult;
  final Result<void>? _passwordResetResult;
  final AuthIdentity? _currentAuth;

  // Track method calls for verification
  int signInCallCount = 0;
  int signOutCallCount = 0;
  String? lastSignInEmail;
  String? lastSignInPassword;

  FakeAuthRepository({
    Result<AuthIdentity>? signInResult,
    Result<AuthIdentity>? signUpResult,
    Result<void>? signOutResult,
    Result<void>? verificationResult,
    Result<void>? passwordResetResult,
    AuthIdentity? currentAuth,
  })  : _signInResult = signInResult,
        _signUpResult = signUpResult,
        _signOutResult = signOutResult,
        _verificationResult = verificationResult,
        _passwordResetResult = passwordResetResult,
        _currentAuth = currentAuth;

  // Factory: Success scenario
  factory FakeAuthRepository.success({AuthIdentity? auth}) {
    final testAuth = auth ?? createTestAuth();
    return FakeAuthRepository(
      signInResult: Result.success(testAuth),
      signUpResult: Result.success(testAuth),
      signOutResult: const Result.success(null),
      verificationResult: const Result.success(null),
      passwordResetResult: const Result.success(null),
      currentAuth: testAuth,
    );
  }

  // Factory: Invalid credentials failure
  factory FakeAuthRepository.invalidCredentials() {
    return FakeAuthRepository(
      signInResult: Result.failure(
        UnauthorizedError(
          message: 'メールアドレスまたはパスワードが正しくありません',
          code: 'INVALID_CREDENTIALS',
        ),
      ),
    );
  }

  // Factory: Network error
  factory FakeAuthRepository.networkError() {
    return FakeAuthRepository(
      signInResult: Result.failure(
        NetworkError(
          message: 'ネットワークエラーが発生しました',
          statusCode: 500,
        ),
      ),
    );
  }

  // Factory: User not found error
  factory FakeAuthRepository.userNotFound() {
    return FakeAuthRepository(
      signInResult: Result.failure(
        NotFoundError(message: 'ユーザーが見つかりません'),
      ),
    );
  }

  @override
  Future<Result<AuthIdentity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signInCallCount++;
    lastSignInEmail = email;
    lastSignInPassword = password;

    return _signInResult ??
        Result.failure(
          UnauthorizedError(message: 'Not configured'),
        );
  }

  @override
  Future<Result<AuthIdentity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _signUpResult ??
        Result.failure(
          UnauthorizedError(message: 'Not configured'),
        );
  }

  @override
  Future<Result<void>> signOut() async {
    signOutCallCount++;
    return _signOutResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    return _verificationResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    return _passwordResetResult ?? const Result.success(null);
  }

  @override
  Stream<AuthIdentity?> observeAuthState() {
    return Stream.value(_currentAuth);
  }

  @override
  Future<Result<AuthIdentity>> getCurrentAuth() async {
    final auth = _currentAuth;
    return auth == null
        ? Result.failure(UnauthorizedError(message: 'ログインしていません'))
        : Result.success(auth);
  }

  @override
  Future<Result<AuthIdentity>> reloadCurrentAuth() => getCurrentAuth();
}
