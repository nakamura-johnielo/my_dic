import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;
import 'package:my_dic/features/search/port/model/search_conjugation_match.dart';

/// Search が必要とする Catalog ゲートウェイが返す、プロバイダー非依存のページです。
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

final class SearchFrequencyMetadata {
  SearchFrequencyMetadata(this.value) {
    if (value < 0) {
      throw ArgumentError.value(value, 'value', 'must not be negative');
    }
  }

  final int value;
}

final class SearchRankingMetadata {
  const SearchRankingMetadata(this.rankingNo);

  final int rankingNo;
}
