import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/model/catalog_search_models.dart';
import 'package:my_dic/features/catalog/port/query/catalog_conjugation_search_query.dart';
import 'package:my_dic/features/catalog/port/result/catalog_search_page.dart';

abstract interface class CatalogConjugationSearchReaderPort {
  Future<Result<CatalogSearchPage<CatalogConjugationSearchHit>>>
      searchConjugations(CatalogConjugationSearchQuery query);
}
