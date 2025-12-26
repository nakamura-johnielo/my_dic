import 'package:my_dic/core/shared/errors/app_error.dart';

class UnexpectedError extends AppError {
  const UnexpectedError({
    required super.message,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: code ?? 'UNEXPECTED_ERROR',
        );
}