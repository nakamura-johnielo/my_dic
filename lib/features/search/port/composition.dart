import 'catalog_gateway.dart';
import 'reader.dart';
import '../internal/search_reader.dart';

/// Pure Search composition root. App supplies the Catalog-backed gateway.
SearchQueryPort createSearchComposition(SearchCatalogGateway gateway) =>
    InternalSearchQueryPort(gateway);
