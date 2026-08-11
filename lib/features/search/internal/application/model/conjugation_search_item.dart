import 'package:my_dic/features/search/internal/application/model/search_conjugation_match_key.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

/// A conjugation suggestion returned alongside a dictionary search page.
class ConjugationSearchItem {
  ConjugationSearchItem({
    required this.wordId,
    required this.word,
    required this.headword,
    required Map<SearchConjugationMatchKey, String> matches,
    required this.meaningText,
    required this.rankingNo,
    required this.starCount,
  }) : matches = Map.unmodifiable(matches);

  final int wordId;

  /// Canonical identity for navigation and live dictionary status.
  final CatalogWordRef word;
  final String headword;
  final Map<SearchConjugationMatchKey, String> matches;

  /// Full plain-text meaning for the suggested verb.
  final String? meaningText;
  final int? rankingNo;
  final int? starCount;
}
