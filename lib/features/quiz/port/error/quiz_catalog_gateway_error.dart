import 'package:my_dic/core/shared/errors/app_error.dart';

/// Quiz の境界語彙に変換された Catalog の失敗。
final class QuizCatalogGatewayError extends AppError {
  const QuizCatalogGatewayError({
    required this.operation,
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(code: 'QUIZ_CATALOG_GATEWAY_FAILURE');

  final String operation;
}
