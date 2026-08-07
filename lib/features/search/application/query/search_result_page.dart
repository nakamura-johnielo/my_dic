import 'package:my_dic/core/application/query/query_issue.dart';
import 'package:my_dic/features/search/application/query/conjugation_search_item.dart';
import 'package:my_dic/features/search/application/query/search_result_item.dart';

/// A paged Search response, including non-fatal enrichment failures.
class SearchResultPage {
  SearchResultPage({
    required List<SearchResultItem> items,
    required List<ConjugationSearchItem> conjugationSuggestions,
    required this.hasNext,
    required List<QueryIssue> issues,
  })  : items = List.unmodifiable(items),
        conjugationSuggestions = List.unmodifiable(conjugationSuggestions),
        issues = List.unmodifiable(issues);

  final List<SearchResultItem> items;
  final List<ConjugationSearchItem> conjugationSuggestions;
  final bool hasNext;
  final List<QueryIssue> issues;
}
