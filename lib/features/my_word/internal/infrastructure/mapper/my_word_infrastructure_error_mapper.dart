import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';

/// MyWord インフラストラクチャ境界における技術固有の失敗を、アプリケーションおよび公開ポートが
/// 理解する型付きエラーへ変換する。
final class MyWordInfrastructureErrorMapper {
  const MyWordInfrastructureErrorMapper._();

  static AppError database(
    Object error,
    StackTrace stackTrace, {
    required String message,
  }) =>
      error is AppError
          ? error
          : DatabaseError(
              message: message,
              originalError: error,
              stackTrace: stackTrace,
            );

  static AppError firebase(
    Object error,
    StackTrace stackTrace, {
    required String message,
  }) =>
      error is AppError
          ? error
          : FirebaseError(
              message: message,
              originalError: error,
              stackTrace: stackTrace,
            );
}
