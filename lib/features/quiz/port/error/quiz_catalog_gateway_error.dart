import 'package:my_dic/core/shared/errors/app_error.dart';

/// A Catalog failure translated into Quiz's boundary vocabulary.
final class QuizCatalogGatewayError extends AppError {
  const QuizCatalogGatewayError({
    required this.operation,
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(code: 'QUIZ_CATALOG_GATEWAY_FAILURE');

  final String operation;
}
