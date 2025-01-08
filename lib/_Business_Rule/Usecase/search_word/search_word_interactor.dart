import 'package:my_dic/_Business_Rule/Usecase/search_word/i_search_word_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_output_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_word_repository.dart';

class SearchWordInteractor implements ISearchWordUseCase {
  final IEsjWordRepository _wordRepository;
  final ISearchWordPresenter _presenter;
  SearchWordInteractor(this._wordRepository, this._presenter);

  @override
  void execute(SearchWordInputData input) async {
    List<Word> l = await _wordRepository.getWordsByWord(input.word);

    SearchWordOutputData result = SearchWordOutputData(l);

    _presenter.execute(result);
  }

  @override
  void emptyExecute() {
    /* List<Word> res = [
      Word(wordId: 1, word: "aplle", partOfSpeech: PartOfSpeech.adverb),
      Word(wordId: 1, word: "2aplle2", partOfSpeech: PartOfSpeech.adverb),
      Word(wordId: 1, word: "3aplle", partOfSpeech: PartOfSpeech.adverb),
    ]; */
    List<Word> res = [];
    SearchWordOutputData result = SearchWordOutputData(res);

    _presenter.execute(result);
  }
}
