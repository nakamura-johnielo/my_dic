import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/enums/dictionary/dictionary_type.dart';

/// User input is deliberately separate from the result lifecycle.
class SearchState {
  const SearchState(
      {this.query = '', this.results = const QueryState.initial()});

  final String query;
  final QueryState<SearchResults> results;

  SearchState copyWith({String? query, QueryState<SearchResults>? results}) =>
      SearchState(query: query ?? this.query, results: results ?? this.results);

  // Transitional read-only accessors for the unused copy fragment.
  List<EspJpnWord> get espJpnWords =>
      results.dataOrNull?.espJpnWords ?? const [];
  List<JpnEspWord> get jpnEspWords =>
      results.dataOrNull?.jpnEspWords ?? const [];
  List<SearchResultConjugacions> get conjugacions =>
      results.dataOrNull?.conjugacions ?? const [];
}

class SearchResults {
  const SearchResults({
    this.espJpnWords = const [],
    this.jpnEspWords = const [],
    this.conjugacions = const [],
    this.rankingNos = const {},
    this.simpleMeanings = const {},
    this.starCounts = const {},
  });

  final List<EspJpnWord> espJpnWords;
  final List<JpnEspWord> jpnEspWords;
  final List<SearchResultConjugacions> conjugacions;
  final Map<int, int> rankingNos;
  final Map<int, String> simpleMeanings;
  final Map<int, int> starCounts;

  bool get isEmpty =>
      espJpnWords.isEmpty && jpnEspWords.isEmpty && conjugacions.isEmpty;
  DictionaryType get activeDictionaryType =>
      jpnEspWords.isNotEmpty ? DictionaryType.jpnEsp : DictionaryType.espJpn;

  SearchResults merge(SearchResults next, {required bool append}) => !append
      ? next
      : SearchResults(
          espJpnWords: [...espJpnWords, ...next.espJpnWords],
          jpnEspWords: [...jpnEspWords, ...next.jpnEspWords],
          conjugacions:
              next.conjugacions.isEmpty ? conjugacions : next.conjugacions,
          rankingNos: {...rankingNos, ...next.rankingNos},
          simpleMeanings: {...simpleMeanings, ...next.simpleMeanings},
          starCounts: {...starCounts, ...next.starCounts},
        );
}
