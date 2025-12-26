
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';

part '../../../__generated/core/shared/utils/result.freezed.dart';

/// 成功・失敗を表現する型
@freezed
class Result<T> with _$Result<T> {
  const Result._();
  
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(AppError error) = Failure<T>;

  /// 成功時の値を取得（失敗時はnull）
  T? get dataOrNull => when(
        success: (data) => data,
        failure: (_) => null,
      );

  /// エラーを取得（成功時はnull）
  AppError? get errorOrNull => when(
        success: (_) => null,
        failure: (error) => error,
      );

  /// 成功かどうか
  bool get isSuccess => this is Success<T>;

  /// 失敗かどうか
  bool get isFailure => this is Failure<T>;

  /// map処理（成功時のみ適用）
  Result<R> map<R>(R Function(T data) transform) {
    return when(
      success: (data) {
        try {
          return Result.success(transform(data));
        } catch (e, s) {
          return Result.failure(
            BusinessRuleError(
              message: 'Transform failed: $e',
              originalError: e,
              stackTrace: s,
            ),
          );
        }
      },
      failure: (error) => Result.failure(error),
    );
  }

  /// flatMap処理（ResultをResultに変換）
  Future<Result<R>> flatMap<R>(
    Future<Result<R>> Function(T data) transform,
  ) async {
    return when(
      success: (data) async {
        try {
          return await transform(data);
        } catch (e, s) {
          return Result.failure(
            BusinessRuleError(
              message: 'Transform failed: $e',
              originalError: e,
              stackTrace: s,
            ),
          );
        }
      },
      failure: (error) => Result.failure(error),
    );
  }
}
