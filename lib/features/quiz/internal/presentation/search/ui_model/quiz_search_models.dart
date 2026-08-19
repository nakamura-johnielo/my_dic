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

    // Catalog 単語は Quiz 候補の安定した識別子である。ページが重なった場合は最初の結果を保持し、
    // 再実行や再試行による重複を防ぐ。
    final seen = <Object>{};
    final merged = <QuizCandidate>[];
    for (final candidate in [...items, ...next.items]) {
      if (seen.add(candidate.word)) merged.add(candidate);
    }
    return QuizSearchResults(items: merged, hasNext: next.hasNext);
  }
}
