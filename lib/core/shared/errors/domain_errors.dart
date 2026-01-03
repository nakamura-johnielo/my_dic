import 'package:my_dic/core/shared/errors/app_error.dart';

/// リソースが見つからない
class NotFoundError extends AppError {
  NotFoundError({
    required super.message,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: code ?? 'NOT_FOUND',
        );
}

class UserNotFoundError extends NotFoundError {
  UserNotFoundError({
    required super.message,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: code ?? 'USER_NOT_FOUND',
        );
}

class DeviceNotFoundError extends NotFoundError {
  DeviceNotFoundError({
    required super.message,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: code ?? 'DEVICE_ID_NOT_FOUND',
        );
}

/// バリデーションエラー
class ValidationError extends AppError {
  final Map<String, List<String>>? fieldErrors;

  ValidationError({
    required super.message,
    this.fieldErrors,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: code ?? 'VALIDATION_ERROR',
        );
}

/// ビジネスルール違反
class BusinessRuleError extends AppError {
  BusinessRuleError({
    required super.message,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: code ?? 'BUSINESS_RULE_ERROR',
        );
}

/// 権限エラー
class UnauthorizedError extends AppError {
  UnauthorizedError({
    required super.message,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: code ?? 'UNAUTHORIZED',
        );
}
