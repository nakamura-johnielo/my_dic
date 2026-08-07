import 'package:my_dic/core/domain/entity/word/word.dart';
import 'package:my_dic/core/domain/i_repository/i_conjugation_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_word_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_word_repository.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/application/usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/features/search/application/usecase/search_word/search_word_input_data.dart';
import 'package:my_dic/features/search/application/usecase/search_word/search_word_output_data.dart';

class SearchWordInteractor implements ISearchWordUseCase {
  SearchWordInteractor(this._words, this._jpnEspWords, this._conjugations);
  final IEsjWordRepository _words;
  final IJpnEspWordRepository _jpnEspWords;
  final IConjugacionsRepository _conjugations;

  @override
  Future<Result<SearchWordOutputData>> executeEspJpn(
      SearchWordInputData input) async {
    if (input.word.trim().isEmpty) {
      return Result.failure(
          ValidationError(message: 'A search word is required.'));
    }
    final result = await _words.getWordsByWordByPage(
        input.word, input.size, input.page, input.forQuiz);
    return result.when(
        success: (words) async {
          final records =
              await _espJpnRecords(words.map((word) => word.wordId).toList());
          return Result.success(SearchWordOutputData(words,
              rankingNos: records.rankingNos,
              simpleMeanings: records.simpleMeanings,
              starCounts: records.starCounts,
              warnings: records.warnings));
        },
        failure: Result.failure);
  }

  @override
  Future<Result<SearchQuizOutputData>> executeVerbs(
      SearchWordInputData input) async {
    final result = await _conjugations.getQuizConjugacionByWordWithPage(
        input.word, input.size, input.page);
    return result.when(
        success: (items) async {
          final records =
              await _espJpnRecords(items.map((item) => item.wordId).toList());
          return Result.success(SearchQuizOutputData(items,
              rankingNos: records.rankingNos,
              simpleMeanings: records.simpleMeanings,
              starCounts: records.starCounts,
              warnings: records.warnings));
        },
        failure: Result.failure);
  }

  @override
  SearchWordOutputData executeEmptyQuery() =>
      const SearchWordOutputData(<EspJpnWord>[]);

  @override
  Future<Result<SearchJpnEspWordOutputData>> executeJpnEsp(
      SearchJpnEspWordInputData input) async {
    if (input.word.trim().isEmpty) {
      return Result.failure(
          ValidationError(message: 'A search word is required.'));
    }
    final result =
        await _jpnEspWords.getWordsByWord(input.word, input.size, input.page);
    return result.when(
        success: (words) async {
          final records =
              await _jpnEspRecords(words.map((word) => word.id).toList());
          return Result.success(SearchJpnEspWordOutputData(words,
              rankingNos: records.rankingNos,
              simpleMeanings: records.simpleMeanings,
              starCounts: records.starCounts,
              warnings: records.warnings));
        },
        failure: Result.failure);
  }

  @override
  Future<Result<SearchConjugacionOutputData>> executeConjugacion(
      SearchConjugacionInputData input) async {
    if (input.word.trim().isEmpty) {
      return Result.failure(
          ValidationError(message: 'A search word is required.'));
    }
    final result = await _conjugations.getConjugacionByWordWithPage(
        input.word, input.size, input.page);
    return result.when(
        success: (items) async {
          final records =
              await _espJpnRecords(items.map((item) => item.wordId).toList());
          return Result.success(SearchConjugacionOutputData(items,
              rankingNos: records.rankingNos,
              simpleMeanings: records.simpleMeanings,
              starCounts: records.starCounts,
              warnings: records.warnings));
        },
        failure: Result.failure);
  }

  Future<_OutputRecords> _espJpnRecords(List<int> wordIds) => _records(
      _words.getRankingNosByWordIds(wordIds),
      _words.getSimpleMeaningsByWordIds(wordIds),
      _words.getStarCountsByWordIds(wordIds));
  Future<_OutputRecords> _jpnEspRecords(List<int> wordIds) => _records(
      _jpnEspWords.getRankingNosByWordIds(wordIds),
      _jpnEspWords.getSimpleMeaningsByWordIds(wordIds),
      _jpnEspWords.getStarCountsByWordIds(wordIds));

  Future<_OutputRecords> _records(
      Future<Result<Map<int, int>>> ranking,
      Future<Result<Map<int, String>>> meaning,
      Future<Result<Map<int, int>>> stars) async {
    final rankingResult = await ranking;
    final meaningResult = await meaning;
    final starsResult = await stars;
    final warnings = <SearchSupplementaryFailure>[];
    final rankingNos = rankingResult.when(
      success: (data) => data,
      failure: (error) {
        warnings
            .add(SearchSupplementaryFailure(source: 'ranking', error: error));
        return const <int, int>{};
      },
    );
    final simpleMeanings = meaningResult.when(
      success: (data) => data,
      failure: (error) {
        warnings
            .add(SearchSupplementaryFailure(source: 'meaning', error: error));
        return const <int, String>{};
      },
    );
    final starCounts = starsResult.when(
      success: (data) => data,
      failure: (error) {
        warnings
            .add(SearchSupplementaryFailure(source: 'starCount', error: error));
        return const <int, int>{};
      },
    );
    return _OutputRecords(rankingNos, simpleMeanings, starCounts, warnings);
  }
}

class _OutputRecords {
  const _OutputRecords(
      this.rankingNos, this.simpleMeanings, this.starCounts, this.warnings);
  final Map<int, int> rankingNos;
  final Map<int, String> simpleMeanings;
  final Map<int, int> starCounts;
  final List<SearchSupplementaryFailure> warnings;
}
