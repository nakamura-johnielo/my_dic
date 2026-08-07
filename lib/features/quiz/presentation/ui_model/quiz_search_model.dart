import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/search/application/query/conjugation_search_item.dart';

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
  });
  final List<ConjugationSearchItem> items;
  bool get isEmpty => items.isEmpty;

  QuizSearchResults merge(QuizSearchResults next, {required bool append}) =>
      !append
          ? next
          : QuizSearchResults(
              items: [...items, ...next.items],
            );
}
