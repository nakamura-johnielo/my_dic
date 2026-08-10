import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/port/model/search_direction.dart';
import 'package:my_dic/features/search/port/model/search_query.dart';
import 'package:my_dic/features/search/port/reader.dart';
import 'package:my_dic/features/search/internal/presentation/ui_model/search_ui_model.dart';

class SearchViewModel extends StateNotifier<SearchState> {
  SearchViewModel(this._search) : super(const SearchState());
  final SearchReader _search;
  final _logger = Logger('SearchViewModel');
  int _generation = 0;

  void updateQuery(String query) {
    final value = query.trim();
    _generation++;
    state = SearchState(
        query: value,
        results: value.isEmpty ? const QueryState.initial() : state.results);
  }

  void clearResults() {
    _generation++;
    state =
        SearchState(query: state.query, results: const QueryState.initial());
  }

  Future<bool> loadSearchResults(int size, int page) async {
    final query = state.query;
    if (query.isEmpty || state.results.isLoading) return false;
    final generation = ++_generation;
    final previous = state.results.dataOrNull;
    state = state.copyWith(results: QueryState.loading(previousData: previous));
    final direction = _directionFor(query);
    final result = await _search.search(SearchQuery(
      text: query,
      direction: direction,
      page: page,
      size: size,
      includeConjugationSuggestions: direction == SearchDirection.espJpn,
    ));
    if (!_isCurrent(generation, query)) return false;
    return result.when(
      success: (output) {
        _publish(
          SearchResults(
            items: output.items,
            conjugationSuggestions: output.conjugationSuggestions,
            hasNext: output.hasNext,
          ),
          previous,
          page > 0,
          warnings: output.issues
              .map((issue) =>
                  QueryWarning(source: issue.source, error: issue.error))
              .toList(growable: false),
        );
        return output.hasNext;
      },
      failure: (error) {
        _fail(error, previous);
        return false;
      },
    );
  }

  bool _isCurrent(int generation, String query) =>
      mounted && generation == _generation && query == state.query;
  SearchDirection _directionFor(String query) {
    try {
      return RegExp(r'[a-zA-Záéíóúñü]').hasMatch(query)
          ? SearchDirection.espJpn
          : SearchDirection.jpnEsp;
    } catch (error) {
      _logger.warning('Dictionary judgement failed', error);
      return SearchDirection.espJpn;
    }
  }
  void _fail(AppError error, SearchResults? previous) {
    if (mounted) {
      state = state.copyWith(
          results: QueryState.failure(error, previousData: previous));
    }
  }

  void _publish(SearchResults next, SearchResults? previous, bool append,
      {List<QueryWarning> warnings = const []}) {
    final value = previous?.merge(next, append: append) ?? next;
    state = state.copyWith(
        results: value.isEmpty
            ? QueryState.empty(warnings: warnings)
            : QueryState.data(value, warnings: warnings));
  }
}
