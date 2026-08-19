import 'package:my_dic/features/search/internal/composition/search_composition_factory.dart';
import 'package:my_dic/features/search/port/search.dart';

/// Search 機能を組み立てるためにアプリケーションが所有する依存関係です。
final class SearchDependencies {
  const SearchDependencies({required this.catalogGateway});

  final SearchCatalogGateway catalogGateway;
}

/// アプリケーションスコープに提供される完全な Search 機能です。
final class SearchPorts {
  const SearchPorts({required this.reader});

  final SearchQueryPort reader;
}

/// フレームワーク状態なしで Search の内部ポリシーグラフを組み立てます。
SearchPorts createSearchComposition({
  required SearchDependencies dependencies,
}) =>
    SearchPorts(
      reader: createInternalSearchReader(
        catalogGateway: dependencies.catalogGateway,
      ),
    );
