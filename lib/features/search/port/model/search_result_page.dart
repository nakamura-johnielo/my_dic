import 'package:my_dic/core/shared/errors/app_error.dart';
import 'conjugation_search_item.dart';
import 'search_result_item.dart';

final class SearchIssue {
  const SearchIssue({required this.source, required this.error});
  final String source;
  final AppError error;
}

final class SearchResultPage {
  SearchResultPage(
      {required List<SearchResultItem> items,
      required List<ConjugationSearchItem> conjugationSuggestions,
      required this.hasNext,
      required List<SearchIssue> issues})
      : items = List.unmodifiable(items),
        conjugationSuggestions = List.unmodifiable(conjugationSuggestions),
        issues = List.unmodifiable(issues);
  final List<SearchResultItem> items;
  final List<ConjugationSearchItem> conjugationSuggestions;
  final bool hasNext;
  final List<SearchIssue> issues;
}
