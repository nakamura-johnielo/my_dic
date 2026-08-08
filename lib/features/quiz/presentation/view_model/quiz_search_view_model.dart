import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/presentation/ui_model/quiz_search_model.dart';
import 'package:my_dic/features/search/application/query/search_direction.dart';
import 'package:my_dic/features/search/application/query/search_query.dart';
import 'package:my_dic/features/search/application/usecase/search_word/i_search_word_use_case.dart';

class QuizSearchViewModel extends StateNotifier<QuizSearchState> {
  QuizSearchViewModel(this._search) : super(const QuizSearchState());
  final ISearchWordUseCase _search;
  int _generation = 0;
  void updateQuery(String query) {
    final value = query.trim();
    _generation++;
    state = QuizSearchState(
        query: value,
        results: value.isEmpty ? const QueryState.initial() : state.results);
  }

  void clearResults() {
    _generation++;
    state = QuizSearchState(
        query: state.query, results: const QueryState.initial());
  }

  /// Loads a zero-based page of quiz search results.
  Future<bool> loadSearchResults(int size, int page) async {
    final query = state.query;
    if (query.isEmpty || state.results.isLoading) return false;
    final generation = ++_generation;
    final previous = state.results.dataOrNull;
    state = state.copyWith(results: QueryState.loading(previousData: previous));
    final result = await _search.executeQuiz(SearchQuery(
      text: query,
      direction: SearchDirection.espJpn,
      page: page,
      size: size,
      includeConjugationSuggestions: false,
    ));
    if (!mounted || generation != _generation || query != state.query) {
      return false;
    }
    return result.when(success: (output) {
      final next = QuizSearchResults(
        items: output.conjugationSuggestions,
        hasNext: output.hasNext,
      );
      final value = previous?.merge(next, append: page > 0) ?? next;
      final warnings = output.issues
          .map((w) => QueryWarning(source: w.source, error: w.error))
          .toList();
      state = state.copyWith(
          results: value.isEmpty
              ? QueryState.empty(warnings: warnings)
              : QueryState.data(value, warnings: warnings));
      return output.hasNext;
    }, failure: (error) {
      state = state.copyWith(
          results: QueryState.failure(error, previousData: previous));
      return false;
    });
  }
}
