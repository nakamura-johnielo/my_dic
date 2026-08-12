import 'package:my_dic/features/catalog/port/catalog.dart';
import 'search_direction.dart';

extension SearchDirectionCatalogWordRef on SearchDirection {
  CatalogId get catalogId => switch (this) {
        SearchDirection.espJpn => CatalogId.espJpnMain,
        SearchDirection.jpnEsp => CatalogId.jpnEspMain,
      };

  CatalogWordRef wordRef(int wordId) =>
      CatalogWordRef(catalogId: catalogId, wordId: wordId);
}
