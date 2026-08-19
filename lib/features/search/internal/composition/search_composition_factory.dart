import 'package:my_dic/features/search/internal/application/search_application_service.dart';
import 'package:my_dic/features/search/port/search.dart';

/// Search 所有のアプリケーションサービスグラフの組み立てです。
SearchQueryPort createInternalSearchReader({
  required SearchCatalogGateway catalogGateway,
}) =>
    SearchApplicationService(catalogGateway);
