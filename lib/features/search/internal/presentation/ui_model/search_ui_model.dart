import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/search/port/search.dart';

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
    required this.direction,
    required List<SearchResultItem> items,
    required List<SearchConjugationSuggestion> conjugationSuggestions,
    required this.hasNext,
  })  : items = List.unmodifiable(items),
        conjugationSuggestions = List.unmodifiable(conjugationSuggestions);

  final SearchDirection direction;
  final List<SearchResultItem> items;
  final List<SearchConjugationSuggestion> conjugationSuggestions;
  final bool hasNext;

  bool get isEmpty => items.isEmpty && conjugationSuggestions.isEmpty;
  SearchResults merge(SearchResults next, {required bool append}) => !append
      ? next
      : SearchResults(
          direction: next.direction,
          items: _dedupeItems([...items, ...next.items]),
          conjugationSuggestions: _dedupeConjugations([
            ...conjugationSuggestions,
            ...next.conjugationSuggestions,
          ]),
          hasNext: next.hasNext,
        );

  static List<SearchResultItem> _dedupeItems(List<SearchResultItem> values) {
    final seen = <Object>{};
    return values.where((item) => seen.add(item.word)).toList(growable: false);
  }

  static List<SearchConjugationSuggestion> _dedupeConjugations(
      List<SearchConjugationSuggestion> values) {
    final seen = <Object>{};
    return values.where((item) => seen.add(item.word)).toList(growable: false);
  }
}
