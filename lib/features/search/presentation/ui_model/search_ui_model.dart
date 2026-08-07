import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/search/application/query/conjugation_search_item.dart';
import 'package:my_dic/features/search/application/query/search_direction.dart';
import 'package:my_dic/features/search/application/query/search_result_item.dart';

/// User input is deliberately separate from the result lifecycle.
class SearchState {
  const SearchState(
      {this.query = '', this.results = const QueryState.initial()});

  final String query;
  final QueryState<SearchResults> results;

  SearchState copyWith({String? query, QueryState<SearchResults>? results}) =>
      SearchState(query: query ?? this.query, results: results ?? this.results);
}

class SearchResults {
  SearchResults({
    required List<SearchResultItem> items,
    required List<ConjugationSearchItem> conjugationSuggestions,
    required this.hasNext,
  })  : items = List.unmodifiable(items),
        conjugationSuggestions = List.unmodifiable(conjugationSuggestions);

  final List<SearchResultItem> items;
  final List<ConjugationSearchItem> conjugationSuggestions;
  final bool hasNext;

  bool get isEmpty => items.isEmpty && conjugationSuggestions.isEmpty;
  SearchDirection get direction =>
      items.isNotEmpty ? items.first.direction : SearchDirection.espJpn;

  SearchResults merge(SearchResults next, {required bool append}) => !append
      ? next
      : SearchResults(
          items: [...items, ...next.items],
          conjugationSuggestions: next.conjugationSuggestions.isEmpty
              ? conjugationSuggestions
              : next.conjugationSuggestions,
          hasNext: next.hasNext,
        );
}
