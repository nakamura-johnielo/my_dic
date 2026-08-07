import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/presentation/ui_model/quiz_search_model.dart';
import 'package:my_dic/features/search/application/usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/features/search/application/usecase/search_word/search_word_input_data.dart';
import 'package:my_dic/router/navigator_service.dart';

class QuizSearchViewModel extends StateNotifier<QuizSearchState> {
  QuizSearchViewModel(this._search, this._navigator)
      : super(const QuizSearchState());
  final ISearchWordUseCase _search;
  final AppNavigatorService _navigator;
  int _generation = 0;
  void goToQuiz(QuizGameRoute route) => _navigator.toFlashCard(route);
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

  Future<void> loadSearchResults(int size, int currentPage) async {
    final query = state.query;
    if (query.isEmpty || state.results.isLoading) return;
    final generation = ++_generation;
    final previous = state.results.dataOrNull;
    state = state.copyWith(results: QueryState.loading(previousData: previous));
    final result = await _search
        .executeVerbs(SearchWordInputData(query, size, currentPage + 1, true));
    if (!mounted || generation != _generation || query != state.query) return;
    result.when(
        success: (output) {
          final next = QuizSearchResults(
              items: output.quizList,
              rankingNos: output.rankingNos,
              simpleMeanings: output.simpleMeanings,
              starCounts: output.starCounts);
          final value = previous?.merge(next, append: currentPage >= 0) ?? next;
          final warnings = output.warnings
              .map((w) => QueryWarning(source: w.source, error: w.error))
              .toList();
          state = state.copyWith(
              results: value.isEmpty
                  ? QueryState.empty(warnings: warnings)
                  : QueryState.data(value, warnings: warnings));
        },
        failure: (error) => state = state.copyWith(
            results: QueryState.failure(error, previousData: previous)));
  }
}
