import 'package:my_dic/core/domain/entity/word/word.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/domain/usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/features/search/domain/usecase/search_word/search_word_input_data.dart';
import 'package:my_dic/features/search/domain/usecase/search_word/search_word_output_data.dart';
import 'package:my_dic/features/quiz/domain/entity/quiz_searched_item.dart';
import 'package:my_dic/core/domain/i_repository/i_conjugation_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_word_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_word_repository.dart';

class SearchWordInteractor implements ISearchWordUseCase {
  final IEsjWordRepository _wordRepository;
  final IJpnEspWordRepository _jpnEspWordRepository;
  final IConjugacionsRepository _conjugacionsRepository;
  SearchWordInteractor(this._wordRepository, this._jpnEspWordRepository,
      this._conjugacionsRepository);

  @override
  Future<Result<SearchWordOutputData>> executeEspJpn(
      SearchWordInputData input) async {
    // 検索クエリのバリデーション
    if (input.word.trim().isEmpty) {
      return Result.failure(ValidationError(
        message: '検索キーワードを入力してください',
      ));
    }

    final result = await _wordRepository.getWordsByWordByPage(
        input.word, input.size, input.page, input.forQuiz);

    return await result.when(
      success: (words) async {
        final wordIds = words.map((w) => w.wordId).toList();
        AppLogger.print("============serchUsecase============================");
        AppLogger.print("wordIds: $wordIds");

        final res = await _getOutputRecords(wordIds);

        return Result.success(SearchWordOutputData(
          words,
          rankingNos: res.rankingNos,
          simpleMeanings: res.simpleMeanings,
          starCounts: res.starCounts,
        ));
      },
      failure: (err) async => Result.failure(err),
    );
  }

  @override
  Future<Result<SearchQuizOutputData>> executeVerbs(
      SearchWordInputData input) async {
    final result = await _conjugacionsRepository
        .getQuizConjugacionByWordWithPage(input.word, input.size, input.page);

    
    return await result.when(
      success: (quizSearchedItems) async {
        final wordIds = quizSearchedItems.map((w) => w.wordId).toList();
        AppLogger.print("============serchUsecase============================");
        AppLogger.print("wordIds: $wordIds");

        final res = await _getOutputRecords(wordIds);

        return Result.success(SearchQuizOutputData(
          quizSearchedItems,
          rankingNos: res.rankingNos,
          simpleMeanings: res.simpleMeanings,
          starCounts: res.starCounts,
        ));
      },
      failure: (err) async => Result.failure(err),
    );
  }

  @override
  SearchWordOutputData executeEmptyQuery() {
    List<EspJpnWord> res = [];
    SearchWordOutputData result = SearchWordOutputData(res);
    return result;
  }

  @override
  Future<Result<SearchJpnEspWordOutputData>> executeJpnEsp(
      SearchJpnEspWordInputData input) async {
    // 検索クエリのバリデーション
    if (input.word.trim().isEmpty) {
      return Result.failure(ValidationError(
        message: '検索キーワードを入力してください',
      ));
    }

    final result = await _jpnEspWordRepository.getWordsByWord(
        input.word, input.size, input.page);

    return result.map((data) => SearchJpnEspWordOutputData(data));
  }

  @override
  Future<Result<SearchConjugacionOutputData>> executeConjugacion(
      SearchConjugacionInputData input) async {
    // 検索クエリのバリデーション
    if (input.word.trim().isEmpty) {
      return Result.failure(ValidationError(
        message: '検索キーワードを入力してください',
      ));
    }

    final result = await _conjugacionsRepository.getConjugacionByWordWithPage(
        input.word, input.size, input.page);

    // return result.map((l) => SearchConjugacionOutputData(l));

    return await result.when(
      success: (conjugaciones) async {
        final wordIds = conjugaciones.map((w) => w.wordId).toList();
        AppLogger.print("============serchUsecase============================");
        AppLogger.print("wordIds: $wordIds");

        final res = await _getOutputRecords(wordIds);

        return Result.success(SearchConjugacionOutputData(
          conjugaciones,
          rankingNos: res.rankingNos,
          simpleMeanings: res.simpleMeanings,
          starCounts: res.starCounts,
        ));
      },
      failure: (err) async => Result.failure(err),
    );
  }

  Future<_OutputRecords> _getOutputRecords(List<int> wordIds) async {
    final rankingFuture = _wordRepository.getRankingNosByWordIds(wordIds);
    final meaningFuture = _wordRepository.getSimpleMeaningsByWordIds(wordIds);
    final starFuture = _wordRepository.getStarCountsByWordIds(wordIds);

    final rankingRes = await rankingFuture;
    final meaningRes = await meaningFuture;
    final starRes = await starFuture;

    final rankingNos = rankingRes.when(
      success: (d) => d,
      failure: (_) => <int, int>{},
    );
    final simpleMeanings = meaningRes.when(
      success: (d) => d,
      failure: (_) => <int, String>{},
    );
    final starCounts = starRes.when(
      success: (d) => d,
      failure: (_) => <int, int>{},
    );

    AppLogger.print("meaning: $simpleMeanings");

    return _OutputRecords(
      rankingNos: rankingNos,
      simpleMeanings: simpleMeanings,
      starCounts: starCounts,
    );
  }
}

class _OutputRecords {
  Map<int, int> rankingNos;
  Map<int, String> simpleMeanings;
  Map<int, int> starCounts;
  _OutputRecords({
    this.rankingNos = const {},
    this.simpleMeanings = const {},
    this.starCounts = const {},
  });
}
