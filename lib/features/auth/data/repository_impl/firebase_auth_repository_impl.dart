import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/data/data_source/remote/i_auth_remote_data_source.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _authDataSource;

  AuthRepositoryImpl(this._authDataSource);

  @override
  Stream<AppAuth?> observeAuthState() {
    return _authDataSource.observeAuthState().map((dto) {
      if (dto == null) return null;
      return AppAuth(
        userId: dto.userId,
        email: dto.email,
        isVerified: dto.emailVerified,
        isLogined: true,
      );
    });
  }

  @override
  Future<Result<AppAuth>> createUserWithEmailAndPassword({required String email, required String password}) async {
    try {
      final dto = await _authDataSource.createUserWithEmailAndPassword(email, password);
      final auth = AppAuth(
        userId: dto.userId,
        email: dto.email,
        isVerified: dto.emailVerified,
        isLogined: false,
      );
      return Result.success(auth);
    } on firebase_auth.FirebaseAuthException catch (e, s) {
      switch (e.code) {
        case 'email-already-in-use':
          return Result.failure(BusinessRuleError(
            message: 'このメールアドレスは既に使用されています',
            code: e.code,
            originalError: e,
            stackTrace: s,
          ));
        case 'invalid-email':
          return Result.failure(ValidationError(
            message: 'メールアドレスの形式が正しくありません',
            code: e.code,
            originalError: e,
            stackTrace: s,
          ));
        case 'weak-password':
          return Result.failure(ValidationError(
            message: 'パスワードは6文字以上にしてください',
            code: e.code,
            originalError: e,
            stackTrace: s,
          ));
        default:
          return Result.failure(FirebaseError(
            message: 'アカウント作成に失敗しました: ${e.message}',
            code: e.code,
            originalError: e,
            stackTrace: s,
          ));
      }
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'アカウント作成中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<AppAuth>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _authDataSource.signInWithEmailAndPassword(email, password);
      final auth = AppAuth(
        userId: dto.userId,
        email: dto.email,
        isVerified: dto.emailVerified,
        isLogined: true,
      );
      return Result.success(auth);
    } on firebase_auth.FirebaseAuthException catch (e, s) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return Result.failure(UnauthorizedError(
            message: 'メールアドレスまたはパスワードが間違っています',
            code: e.code,
            originalError: e,
            stackTrace: s,
          ));
        case 'user-disabled':
          return Result.failure(UnauthorizedError(
            message: 'このアカウントは無効になっています',
            code: e.code,
            originalError: e,
            stackTrace: s,
          ));
        case 'invalid-email':
          return Result.failure(ValidationError(
            message: 'メールアドレスの形式が正しくありません',
            code: e.code,
            originalError: e,
            stackTrace: s,
          ));
        default:
          return Result.failure(FirebaseError(
            message: 'ログインに失敗しました: ${e.message}',
            code: e.code,
            originalError: e,
            stackTrace: s,
          ));
      }
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
      await _authDataSource.signOut();
      return const Result.success(null);
    } on firebase_auth.FirebaseAuthException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'ログアウトに失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
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
      await _authDataSource.sendEmailVerification();
      return const Result.success(null);
    } on firebase_auth.FirebaseAuthException catch (e, s) {
      if (e.code == 'too-many-requests') {
        return Result.failure(BusinessRuleError(
          message: '送信回数が多すぎます。しばらくしてから再度お試しください',
          code: e.code,
          originalError: e,
          stackTrace: s,
        ));
      }
      return Result.failure(FirebaseError(
        message: '確認メールの送信に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
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
      await _authDataSource.sendPasswordResetEmail(email: email);
      return const Result.success(null);
    } on firebase_auth.FirebaseAuthException catch (e, s) {
      switch (e.code) {
        case 'invalid-email':
          return Result.failure(ValidationError(
            message: 'メールアドレスの形式が正しくありません',
            code: e.code,
            originalError: e,
            stackTrace: s,
          ));
        case 'user-not-found':
          return Result.failure(NotFoundError(
            message: 'このメールアドレスは登録されていません',
            code: e.code,
            originalError: e,
            stackTrace: s,
          ));
        default:
          return Result.failure(FirebaseError(
            message: 'パスワードリセットメールの送信に失敗しました: ${e.message}',
            code: e.code,
            originalError: e,
            stackTrace: s,
          ));
      }
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'パスワードリセット中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }


}
