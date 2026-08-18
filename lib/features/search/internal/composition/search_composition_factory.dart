import 'package:my_dic/features/search/internal/application/search_application_service.dart';
import 'package:my_dic/features/search/port/search.dart';

/// Search-owned assembly of the application service graph.
SearchQueryPort createInternalSearchReader({
  required SearchCatalogGateway catalogGateway,
}) =>
    SearchApplicationService(catalogGateway);
