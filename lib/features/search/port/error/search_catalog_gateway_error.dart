import 'package:my_dic/core/shared/errors/app_error.dart';

/// Search が必要とする Catalog コントラクトでサポートされる失敗単位です。
enum SearchCatalogOperation {
  primarySearch,
  conjugationSearch,
  meanings,
  frequencies,
  rankings,
}

/// Search 所有のゲートウェイ用語に変換されたプロバイダーの失敗です。
final class SearchCatalogGatewayError extends AppError {
  const SearchCatalogGatewayError({
    required this.operation,
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(code: 'SEARCH_CATALOG_GATEWAY_FAILURE');

  final SearchCatalogOperation operation;
}
