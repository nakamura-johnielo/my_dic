import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';

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
  const QuizSearchResults({
    this.items = const [],
    this.rankingNos = const {},
    this.simpleMeanings = const {},
    this.starCounts = const {},
  });
  final List<ConjugacionSearchResultItem> items;
  final Map<int, int> rankingNos;
  final Map<int, String> simpleMeanings;
  final Map<int, int> starCounts;
  bool get isEmpty => items.isEmpty;

  QuizSearchResults merge(QuizSearchResults next, {required bool append}) =>
      !append
          ? next
          : QuizSearchResults(
              items: [...items, ...next.items],
              rankingNos: {...rankingNos, ...next.rankingNos},
              simpleMeanings: {...simpleMeanings, ...next.simpleMeanings},
              starCounts: {...starCounts, ...next.starCounts},
            );
}
