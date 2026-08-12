import 'package:my_dic/core/shared/errors/app_error.dart';

/// A Catalog failure translated into Search's own boundary vocabulary.
final class SearchCatalogGatewayError extends AppError {
  const SearchCatalogGatewayError({
    required this.operation,
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(code: 'SEARCH_CATALOG_GATEWAY_FAILURE');

  final String operation;
}
