/// Fake implementation of IAuthRepository for testing
/// This replaces mockito/mocktail per test_query.md requirements

import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';

import 'test_helpers.dart';

class FakeAuthRepository implements IAuthRepository {
  final Result<AppAuth>? _signInResult;
  final Result<AppAuth>? _signUpResult;
  final Result<void>? _signOutResult;
  final Result<void>? _verificationResult;
  final Result<void>? _passwordResetResult;
  final AppAuth? _currentAuth;

  // Track method calls for verification
  int signInCallCount = 0;
  int signOutCallCount = 0;
  String? lastSignInEmail;
  String? lastSignInPassword;

  FakeAuthRepository({
    Result<AppAuth>? signInResult,
    Result<AppAuth>? signUpResult,
    Result<void>? signOutResult,
    Result<void>? verificationResult,
    Result<void>? passwordResetResult,
    AppAuth? currentAuth,
  })  : _signInResult = signInResult,
        _signUpResult = signUpResult,
        _signOutResult = signOutResult,
        _verificationResult = verificationResult,
        _passwordResetResult = passwordResetResult,
        _currentAuth = currentAuth;

  // Factory: Success scenario
  factory FakeAuthRepository.success({AppAuth? auth}) {
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
  Future<Result<AppAuth>> signInWithEmailAndPassword({
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
  Future<Result<AppAuth>> createUserWithEmailAndPassword({
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
  Stream<AppAuth?> observeAuthState() {
    return Stream.value(_currentAuth);
  }
}
