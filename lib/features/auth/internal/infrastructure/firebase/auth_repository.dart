import 'package:my_dic/features/auth/internal/domain/repository/auth_repository.dart';
import 'package:my_dic/features/auth/port/auth.dart';
import 'package:my_dic/features/auth/port/composition_contract.dart';

final class AuthRepository implements IAuthRepository {
  AuthRepository(this._runtime);

  final AuthRuntimeGateway _runtime;

  @override
  Stream<AuthIdentity?> observeAuthState() =>
      _runtime.observeAuthState().map(_identityOrNull);

  @override
  Future<Result<AuthIdentity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final identity = await _runtime.createUserWithEmailAndPassword(
        email,
        password,
      );
      if (identity == null) {
        return Result.failure(UnexpectedError(
          message: 'アカウント作成に失敗しました',
        ));
      }
      return Result.success(_identity(identity));
    } on AuthRuntimeFailure catch (e) {
      return switch (e.code) {
        'email-already-in-use' => Result.failure(BusinessRuleError(
            message: 'このメールアドレスは既に使用されています',
            code: e.code,
            originalError: e.originalError,
            stackTrace: e.stackTrace,
          )),
        'invalid-email' => Result.failure(ValidationError(
            message: 'メールアドレスの形式が正しくありません',
            code: e.code,
            originalError: e.originalError,
            stackTrace: e.stackTrace,
          )),
        'weak-password' => Result.failure(ValidationError(
            message: 'パスワードは6文字以上にしてください',
            code: e.code,
            originalError: e.originalError,
            stackTrace: e.stackTrace,
          )),
        _ => Result.failure(FirebaseError(
            message: 'アカウント作成に失敗しました: ${e.message}',
            code: e.code,
            originalError: e.originalError,
            stackTrace: e.stackTrace,
          )),
      };
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'アカウント作成中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<AuthIdentity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final identity = await _runtime.signInWithEmailAndPassword(
        email,
        password,
      );
      if (identity == null) {
        return Result.failure(UnexpectedError(
          message: 'アカウントを取得できませんでした',
        ));
      }
      return Result.success(_identity(identity));
    } on AuthRuntimeFailure catch (e) {
      return switch (e.code) {
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          Result.failure(UnauthorizedError(
            message: 'メールアドレスまたはパスワードが間違っています',
            code: e.code,
            originalError: e.originalError,
            stackTrace: e.stackTrace,
          )),
        'user-disabled' => Result.failure(UnauthorizedError(
            message: 'このアカウントは無効になっています',
            code: e.code,
            originalError: e.originalError,
            stackTrace: e.stackTrace,
          )),
        'invalid-email' => Result.failure(ValidationError(
            message: 'メールアドレスの形式が正しくありません',
            code: e.code,
            originalError: e.originalError,
            stackTrace: e.stackTrace,
          )),
        _ => Result.failure(FirebaseError(
            message: 'ログインに失敗しました: ${e.message}',
            code: e.code,
            originalError: e.originalError,
            stackTrace: e.stackTrace,
          )),
      };
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'ログイン中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _runtime.signOut();
      return const Result.success(null);
    } on AuthRuntimeFailure catch (e) {
      return Result.failure(FirebaseError(
        message: 'ログアウトに失敗しました: ${e.message}',
        code: e.code,
        originalError: e.originalError,
        stackTrace: e.stackTrace,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'ログアウト中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      await _runtime.sendEmailVerification();
      return const Result.success(null);
    } on AuthRuntimeFailure catch (e) {
      if (e.code == 'too-many-requests') {
        return Result.failure(BusinessRuleError(
          message: '送信回数が多すぎます。しばらくしてから再度お試しください',
          code: e.code,
          originalError: e.originalError,
          stackTrace: e.stackTrace,
        ));
      }
      return Result.failure(FirebaseError(
        message: '確認メールの送信に失敗しました: ${e.message}',
        code: e.code,
        originalError: e.originalError,
        stackTrace: e.stackTrace,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: '確認メール送信中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    try {
      await _runtime.sendPasswordResetEmail(email: email);
      return const Result.success(null);
    } on AuthRuntimeFailure catch (e) {
      return switch (e.code) {
        'invalid-email' => Result.failure(ValidationError(
            message: 'メールアドレスの形式が正しくありません',
            code: e.code,
            originalError: e.originalError,
            stackTrace: e.stackTrace,
          )),
        'user-not-found' => Result.failure(NotFoundError(
            message: 'このメールアドレスは登録されていません',
            code: e.code,
            originalError: e.originalError,
            stackTrace: e.stackTrace,
          )),
        _ => Result.failure(FirebaseError(
            message: 'パスワードリセットメールの送信に失敗しました: ${e.message}',
            code: e.code,
            originalError: e.originalError,
            stackTrace: e.stackTrace,
          )),
      };
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'パスワードリセット中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<AuthIdentity>> getCurrentAuth() async {
    try {
      final identity = await _runtime.getCurrentAuth();
      if (identity == null) {
        return Result.failure(UnauthorizedError(message: 'ログインしていません'));
      }
      return Result.success(_identity(identity));
    } catch (_) {
      return Result.failure(UnexpectedError(
        message: 'アカウントを取得できませんでした',
      ));
    }
  }

  @override
  Future<Result<AuthIdentity>> reloadCurrentAuth() async {
    try {
      final identity = await _runtime.reloadCurrentAuth();
      if (identity == null) {
        return Result.failure(UnauthorizedError(message: 'ログインしていません'));
      }
      return Result.success(_identity(identity));
    } on AuthRuntimeFailure catch (e) {
      return Result.failure(FirebaseError(
        message: '認証状態の再読み込みに失敗しました: ${e.message}',
        code: e.code,
        originalError: e.originalError,
        stackTrace: e.stackTrace,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: '認証状態の再読み込み中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }
}

AuthIdentity? _identityOrNull(AuthRuntimeIdentity? value) =>
    value == null ? null : _identity(value);

AuthIdentity _identity(AuthRuntimeIdentity value) => AuthIdentity(
      accountId: value.accountId,
      email: value.email,
      emailVerified: value.emailVerified,
      provider: switch (value.credentialProviderId) {
        'google.com' => AuthProvider.google,
        'apple.com' => AuthProvider.apple,
        'password' => AuthProvider.email,
        'anonymous' => AuthProvider.anonymous,
        _ => AuthProvider.unknown,
      },
    );
