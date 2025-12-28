import 'package:my_dic/core/domain/entity/word/word.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
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

    return result.map((words) => SearchWordOutputData(words));
  }

  @override
  Future<Result<List<QuizSearchedItem>>> executeVerbs(SearchWordInputData input) async {
    // List<Word> l = await _wordRepository.getWordsByWord(input.word);
    final result = await _conjugacionsRepository
        .getQuizConjugacionByWordWithPage(input.word, input.size, input.page);

    return result;
  }

  @override
  SearchWordOutputData executeEmptyQuery() {
    /* List<Word> res = [
      Word(wordId: 1, word: "aplle", partOfSpeech: PartOfSpeech.adverb),
      Word(wordId: 1, word: "2aplle2", partOfSpeech: PartOfSpeech.adverb),
      Word(wordId: 1, word: "3aplle", partOfSpeech: PartOfSpeech.adverb),
    ]; */
    List<EspJpnWord> res = [];
    SearchWordOutputData result = SearchWordOutputData(res);
    return result;
    //_presenter.execute(result);
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

    return result.map((l) => SearchConjugacionOutputData(l));
  }
}
