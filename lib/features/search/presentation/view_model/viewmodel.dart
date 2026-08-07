import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/enums/dictionary/dictionary_type.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/application/usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/features/search/application/usecase/search_word/search_word_input_data.dart';
import 'package:my_dic/features/search/application/usecase/search_word/search_word_output_data.dart';
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
    final dictionary = _dictionaryFor(query);
    if (dictionary == DictionaryType.jpnEsp) {
      final result = await _search
          .executeJpnEsp(SearchJpnEspWordInputData(query, size, page));
      if (!_isCurrent(generation, query)) return;
      result.when(
        success: (output) => _publish(
          QuizlessResult.jpn(output).value,
          previous,
          page > 0,
        ),
        failure: (error) => _fail(error, previous),
      );
      return;
    }
    final primary = await _search
        .executeEspJpn(SearchWordInputData(query, size, page, false));
    if (!_isCurrent(generation, query)) return;
    await primary.when(
      success: (output) async {
        var next = QuizlessResult.esp(output);
        var warnings = next.warnings;
        if (page == 0) {
          final conjugation = await _search
              .executeConjugacion(SearchConjugacionInputData(query, 4, 0));
          if (!_isCurrent(generation, query)) return;
          conjugation.when(
            success: (value) {
              next = next.withConjugation(value);
              warnings = [
                ...warnings,
                ...value.warnings
                    .map((w) => QueryWarning(source: w.source, error: w.error))
              ];
            },
            failure: (error) => warnings = [
              ...warnings,
              QueryWarning(source: 'conjugation', error: error)
            ],
          );
        }
        _publish(next.value, previous, page > 0, warnings: warnings);
      },
      failure: (error) async => _fail(error, previous),
    );
  }

  bool _isCurrent(int generation, String query) =>
      mounted && generation == _generation && query == state.query;
  DictionaryType _dictionaryFor(String query) =>
      _judge.execute(JudgeSearchWordInputData(query)).when(
            success: (value) => value.dictionaryType,
            failure: (error) {
              _logger.warning('Dictionary judgement failed', error);
              return DictionaryType.espJpn;
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

class QuizlessResult {
  const QuizlessResult(this.value, this.warnings);
  final SearchResults value;
  final List<QueryWarning> warnings;
  factory QuizlessResult.esp(SearchWordOutputData output) => QuizlessResult(
      SearchResults(
          espJpnWords: output.wordList,
          rankingNos: output.rankingNos,
          simpleMeanings: output.simpleMeanings,
          starCounts: output.starCounts),
      output.warnings
          .map((w) => QueryWarning(source: w.source, error: w.error))
          .toList());
  factory QuizlessResult.jpn(SearchJpnEspWordOutputData output) =>
      QuizlessResult(
          SearchResults(
              jpnEspWords: output.wordList,
              rankingNos: output.rankingNos,
              simpleMeanings: output.simpleMeanings,
              starCounts: output.starCounts),
          output.warnings
              .map((w) => QueryWarning(source: w.source, error: w.error))
              .toList());
  QuizlessResult withConjugation(SearchConjugacionOutputData output) =>
      QuizlessResult(
          SearchResults(
              espJpnWords: value.espJpnWords,
              conjugacions: output.wordList,
              rankingNos: {
                ...value.rankingNos,
                ...output.rankingNos
              },
              simpleMeanings: {
                ...value.simpleMeanings,
                ...output.simpleMeanings
              },
              starCounts: {
                ...value.starCounts,
                ...output.starCounts
              }),
          warnings);
}
