import 'package:my_dic/features/search/port/error/search_issue.dart';
import 'package:my_dic/features/search/port/model/search_direction.dart';
import 'package:my_dic/features/search/port/model/search_result_item.dart';

/// A Search page whose direction and Catalog paging signal are explicit.
final class SearchResultPage {
  SearchResultPage({
    required this.direction,
    required List<SearchResultItem> items,
    required List<SearchConjugationSuggestion> conjugationSuggestions,
    required this.hasNext,
    required List<SearchIssue> issues,
  })  : items = List.unmodifiable(items),
        conjugationSuggestions = List.unmodifiable(conjugationSuggestions),
        issues = List.unmodifiable(issues);

  final SearchDirection direction;
  final List<SearchResultItem> items;
  final List<SearchConjugationSuggestion> conjugationSuggestions;

  /// Catalog's look-ahead fact, never inferred from [items].
  final bool hasNext;

  final List<SearchIssue> issues;
}
