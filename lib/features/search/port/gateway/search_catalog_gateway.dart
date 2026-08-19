import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;
import 'package:my_dic/features/search/port/query/search_catalog_query.dart';
import 'package:my_dic/features/search/port/result/search_catalog_page.dart';

/// Search ユースケースで必要となる、コンシューマー所有の Catalog 機能です。
abstract interface class SearchCatalogGateway {
  Future<Result<SearchCatalogPage<SearchPrimaryHit>>> searchPrimary(
    SearchCatalogQuery query,
  );

  Future<Result<SearchCatalogPage<SearchConjugationHit>>> searchConjugations(
    SearchCatalogQuery query,
  );

  Future<Result<Map<CatalogWordRef, SearchMeaningMetadata>>> readMeanings(
    Iterable<CatalogWordRef> words,
  );

  Future<Result<Map<CatalogWordRef, SearchFrequencyMetadata>>> readFrequencies(
    Iterable<CatalogWordRef> words,
  );

  Future<Result<Map<CatalogWordRef, SearchRankingMetadata>>> readRankings(
    Iterable<CatalogWordRef> words,
  );
}
