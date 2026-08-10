import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/internal/presentation/ui_model/quiz_search_model.dart';
import 'package:my_dic/features/quiz/port/candidate_source.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_query.dart';

class QuizSearchViewModel extends StateNotifier<QuizSearchState> {
  QuizSearchViewModel(this._source) : super(const QuizSearchState());
  final QuizCandidateSource _source;
  int _generation = 0;
  void updateQuery(String query) {
    final value = query.trim();
    _generation++;
    state = QuizSearchState(query: value, results: value.isEmpty ? const QueryState.initial() : state.results);
  }
  Future<bool> loadSearchResults(int size, int page) async {
    final query = state.query;
    if (query.isEmpty || state.results.isLoading) return false;
    final generation = ++_generation;
    final previous = state.results.dataOrNull;
    state = state.copyWith(results: QueryState.loading(previousData: previous));
    final result = await _source.search(QuizCandidateQuery(text: query, page: page, size: size));
    if (!mounted || generation != _generation || query != state.query) return false;
    return result.when(success: (output) {
      final next = QuizSearchResults(items: output.candidates, hasNext: output.hasNext);
      final value = previous?.merge(next, append: page > 0) ?? next;
      final warnings = output.issues.map((w) => QueryWarning(source: w.source, error: w.error)).toList();
      state = state.copyWith(results: value.isEmpty ? QueryState.empty(warnings: warnings) : QueryState.data(value, warnings: warnings));
      return output.hasNext;
    }, failure: (error) {
      state = state.copyWith(results: QueryState.failure(error, previousData: previous));
      return false;
    });
  }
}
