import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/feature_composition/catalog_composition.dart';
import 'package:my_dic/features/search/port/composition.dart';
import 'package:my_dic/features/search/port/search.dart';
import 'package:my_dic/integration/catalog_search/catalog_backed_search_gateway.dart';

/// アプリケーションスコープ用に完成したSearch機能群。
final searchPortsProvider = Provider<SearchPorts>(
  (ref) => createSearchComposition(
    dependencies: SearchDependencies(
      catalogGateway: CatalogBackedSearchGateway(
        ref.watch(catalogQueryPortsProvider),
      ),
    ),
  ),
);

/// プレゼンテーションやその他の利用側に提供する、用途を絞ったSearchリーダー。
final searchReaderPortProvider = Provider<SearchQueryPort>(
  (ref) => ref.watch(searchPortsProvider).reader,
);
