import 'dart:math';

import 'package:my_dic/_Business_Rule/Usecase/search_word/i_search_word_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_output_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/quiz_searched_item.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word/word.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_conjugation_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_word_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_jpn_esp_word_repository.dart';

class SearchWordInteractor implements ISearchWordUseCase {
  final IEsjWordRepository _wordRepository;
  final IJpnEspWordRepository _jpnEspWordRepository;
  final IConjugacionsRepository _conjugacionsRepository;
  final ISearchWordPresenter _presenter;
  SearchWordInteractor(this._wordRepository, this._presenter,
      this._jpnEspWordRepository, this._conjugacionsRepository);

  @override
  Future<void> executeEspJpn(SearchWordInputData input) async {
    // List<Word> l = await _wordRepository.getWordsByWord(input.word);
    List<EspJpnWord> l = await _wordRepository.getWordsByWordByPage(
        input.word, input.size, input.page, input.forQuiz);

    SearchWordOutputData result = SearchWordOutputData(l);

    if (input.page == 0) {
      _presenter.executInicialEspJpn(result);
      return;
    }
    _presenter.executNextEspJpn(result);
  }

  @override
  Future<List<QuizSearchedItem>> executeVerbs(SearchWordInputData input) async {
    // List<Word> l = await _wordRepository.getWordsByWord(input.word);
    List<QuizSearchedItem> l = await _conjugacionsRepository
        .getQuizConjugacionByWordWithPage(input.word, input.size, input.page);
    return l;
  }

  @override
  Future<void> emptyExecute() async {
    /* List<Word> res = [
      Word(wordId: 1, word: "aplle", partOfSpeech: PartOfSpeech.adverb),
      Word(wordId: 1, word: "2aplle2", partOfSpeech: PartOfSpeech.adverb),
      Word(wordId: 1, word: "3aplle", partOfSpeech: PartOfSpeech.adverb),
    ]; */
    List<EspJpnWord> res = [];
    SearchWordOutputData result = SearchWordOutputData(res);

    //_presenter.execute(result);
  }

  @override
  Future<void> executeJpnEsp(SearchJpnEspWordInputData input) async {
    List<JpnEspWord> l = await _jpnEspWordRepository.getWordsByWord(
        input.word, input.size, input.page);

    SearchJpnEspWordOutputData result = SearchJpnEspWordOutputData(l);

    if (input.page == 0) {
      _presenter.executeInicialJpnEsp(result);
      return;
    }
    _presenter.executeNextJpnEsp(result);
  }

  @override
  Future<void> executeConjugacion(SearchConjugacionInputData input) async {
    List<SearchResultConjugacions> l = await _conjugacionsRepository
        .getConjugacionByWordWithPage(input.word, input.size, input.page);

    SearchConjugacionOutputData result = SearchConjugacionOutputData(l);

    if (input.page == 0) {
      _presenter.executInicialConjugacion(result);
      return;
    }
    _presenter.executNextConjugacion(result);
  }
}
