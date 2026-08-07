import 'package:my_dic/features/search/application/query/search_direction.dart';

/// A dictionary search result with optional display enrichment.
class SearchResultItem {
  const SearchResultItem({
    required this.wordId,
    required this.headword,
    required this.direction,
    required this.hasConjugation,
    required this.meaningText,
    required this.rankingNo,
    required this.starCount,
  });

  final int wordId;
  final String headword;
  final SearchDirection direction;
  final bool hasConjugation;

  /// Full plain-text meaning when it exists for this direction.
  final String? meaningText;

  /// Optional enrichment; a missing value is not a query failure.
  final int? rankingNo;
  final int? starCount;
}
