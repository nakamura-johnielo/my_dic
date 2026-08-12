import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/quiz/port/result/quiz_candidate_page.dart';

class QuizSearchState {
  const QuizSearchState(
      {this.query = '', this.results = const QueryState.initial()});
  final String query;
  final QueryState<QuizSearchResults> results;
  QuizSearchState copyWith(
          {String? query, QueryState<QuizSearchResults>? results}) =>
      QuizSearchState(
          query: query ?? this.query, results: results ?? this.results);
}

class QuizSearchResults {
  QuizSearchResults(
      {List<QuizCandidate> items = const [], required this.hasNext})
      : items = List.unmodifiable(items);
  final List<QuizCandidate> items;
  final bool hasNext;
  bool get isEmpty => items.isEmpty;
  QuizSearchResults merge(QuizSearchResults next, {required bool append}) {
    if (!append) return next;

    // A Catalog word is the stable identity of a Quiz candidate.  Keep the
    // first result when pages overlap so replays/retries cannot duplicate it.
    final seen = <Object>{};
    final merged = <QuizCandidate>[];
    for (final candidate in [...items, ...next.items]) {
      if (seen.add(candidate.word)) merged.add(candidate);
    }
    return QuizSearchResults(items: merged, hasNext: next.hasNext);
  }
}
