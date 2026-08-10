import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'search_direction.dart';

extension SearchDirectionCatalogWordRef on SearchDirection {
  CatalogId get catalogId => switch (this) {
        SearchDirection.espJpn => CatalogId.espJpnMain,
        SearchDirection.jpnEsp => CatalogId.jpnEspMain,
      };

  CatalogWordRef wordRef(int wordId) =>
      CatalogWordRef(catalogId: catalogId, wordId: wordId);
}
