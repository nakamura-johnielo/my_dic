import 'package:my_dic/core/shared/errors/app_error.dart';

/// Failure units supported by Search's required Catalog contract.
enum SearchCatalogOperation {
  primarySearch,
  conjugationSearch,
  meanings,
  frequencies,
  rankings,
}

/// A provider failure translated into Search-owned gateway vocabulary.
final class SearchCatalogGatewayError extends AppError {
  const SearchCatalogGatewayError({
    required this.operation,
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(code: 'SEARCH_CATALOG_GATEWAY_FAILURE');

  final SearchCatalogOperation operation;
}
