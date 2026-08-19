import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;
import 'package:my_dic/features/search/port/model/search_conjugation_match.dart';

/// 主要な Search 結果の 1 件です。[word] が唯一の識別子です。
final class SearchResultItem {
  const SearchResultItem({
    required this.word,
    required this.headword,
    required this.hasConjugation,
    this.meaningText,
    this.rankingNo,
    this.starCount,
  });

  final CatalogWordRef word;
  final String headword;
  final bool hasConjugation;
  final String? meaningText;
  final int? rankingNo;
  final int? starCount;
}

/// 主要ページとともに返される活用候補です。
final class SearchConjugationSuggestion {
  SearchConjugationSuggestion({
    required this.word,
    required this.headword,
    required Map<SearchConjugationMatchKey, String> matches,
    this.meaningText,
    this.rankingNo,
    this.starCount,
  }) : matches = Map.unmodifiable(matches);

  final CatalogWordRef word;
  final String headword;
  final Map<SearchConjugationMatchKey, String> matches;
  final String? meaningText;
  final int? rankingNo;
  final int? starCount;
}
