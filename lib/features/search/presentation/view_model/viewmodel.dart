import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/enums/dictionary/dictionary_type.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/application/query/search_direction.dart';
import 'package:my_dic/features/search/application/query/search_query.dart';
import 'package:my_dic/features/search/application/usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/i_judge_search_word_use_case.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/judge_search_word_input_data.dart';
import 'package:my_dic/features/search/presentation/ui_model/search_ui_model.dart';

class SearchViewModel extends StateNotifier<SearchState> {
  SearchViewModel(this._search, this._judge) : super(const SearchState());
  final ISearchWordUseCase _search;
  final IJudgeSearchWordUseCase _judge;
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

  Future<void> loadSearchResults(int size, int currentPage) async {
    final query = state.query;
    if (query.isEmpty || state.results.isLoading) return;
    final page = currentPage + 1;
    final generation = ++_generation;
    final previous = state.results.dataOrNull;
    state = state.copyWith(results: QueryState.loading(previousData: previous));
    final direction = _directionFor(query);
    final result = await _search.execute(SearchQuery(
      text: query,
      direction: direction,
      page: page,
      size: size,
      includeConjugationSuggestions: direction == SearchDirection.espJpn,
    ));
    if (!_isCurrent(generation, query)) return;
    result.when(
      success: (output) => _publish(
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
      ),
      failure: (error) => _fail(error, previous),
    );
  }

  bool _isCurrent(int generation, String query) =>
      mounted && generation == _generation && query == state.query;
  SearchDirection _directionFor(String query) =>
      _judge.execute(JudgeSearchWordInputData(query)).when(
            success: (value) => value.dictionaryType == DictionaryType.jpnEsp
                ? SearchDirection.jpnEsp
                : SearchDirection.espJpn,
            failure: (error) {
              _logger.warning('Dictionary judgement failed', error);
              return SearchDirection.espJpn;
            },
          );
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
