import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'search_conjugation_match_key.dart';

final class ConjugationSearchItem {
  ConjugationSearchItem({required this.wordId, required this.word, required this.headword, required Map<SearchConjugationMatchKey, String> matches, required this.meaningText, required this.rankingNo, required this.starCount}) : matches = Map.unmodifiable(matches);
  final int wordId;
  final CatalogWordRef word;
  final String headword;
  final Map<SearchConjugationMatchKey, String> matches;
  final String? meaningText;
  final int? rankingNo;
  final int? starCount;
}
