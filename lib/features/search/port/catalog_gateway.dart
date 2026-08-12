import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/search/port/error/search_catalog_gateway_error.dart';
import 'package:my_dic/features/search/port/model/search_conjugation_match_key.dart';
import 'package:my_dic/features/search/port/model/search_direction.dart';

/// Consumer-owned boundary used by Search to read dictionary data.
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

  Future<Result<Map<CatalogWordRef, SearchHeadwordMetadata>>>
      readHeadwordMetadata(Iterable<CatalogWordRef> words);

  Future<Result<Map<CatalogWordRef, SearchRankingMetadata>>>
      readRankingMetadata(Iterable<CatalogWordRef> words);
}

final class SearchCatalogQuery {
  const SearchCatalogQuery({
    required this.text,
    required this.direction,
    required this.page,
    required this.size,
  });

  final String text;
  final SearchDirection direction;
  final int page;
  final int size;
}

final class SearchCatalogPage<T> {
  SearchCatalogPage({required List<T> items, required this.hasMore})
      : items = List.unmodifiable(items);

  final List<T> items;
  final bool hasMore;
}

final class SearchPrimaryHit {
  const SearchPrimaryHit({
    required this.word,
    required this.headword,
    required this.hasConjugation,
  });

  final CatalogWordRef word;
  final String headword;
  final bool hasConjugation;
}

final class SearchConjugationHit {
  SearchConjugationHit({
    required this.word,
    required this.headword,
    required Map<SearchConjugationMatchKey, String> matches,
  }) : matches = Map.unmodifiable(matches);

  final CatalogWordRef word;
  final String headword;
  final Map<SearchConjugationMatchKey, String> matches;
}

final class SearchMeaningMetadata {
  const SearchMeaningMetadata(this.text);
  final String text;
}

final class SearchHeadwordMetadata {
  const SearchHeadwordMetadata({
    required this.headword,
    required this.frequency,
  });

  final String headword;
  final int frequency;
}

final class SearchRankingMetadata {
  const SearchRankingMetadata(this.rankingNo);
  final int rankingNo;
}

// Keep the error visible from the gateway contract's normal import surface.
typedef SearchGatewayError = SearchCatalogGatewayError;
