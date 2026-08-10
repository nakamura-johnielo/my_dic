import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'search_direction.dart';

final class SearchResultItem {
  const SearchResultItem({required this.wordId, required this.word, required this.headword, required this.direction, required this.hasConjugation, required this.meaningText, required this.rankingNo, required this.starCount});
  final int wordId;
  final CatalogWordRef word;
  final String headword;
  final SearchDirection direction;
  final bool hasConjugation;
  final String? meaningText;
  final int? rankingNo;
  final int? starCount;
}
