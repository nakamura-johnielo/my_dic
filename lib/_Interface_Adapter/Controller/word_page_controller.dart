import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_dictionary/fetch_dictionary_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_dictionary/i_fetch_dictionary_use_case.dart';

class WordPageController {
  final IFetchDictionaryUseCase _fetchDictionaryUseCase;
  final IFetchConjugationUseCase _fetchConjugationUseCase;

  WordPageController(
      this._fetchDictionaryUseCase, this._fetchConjugationUseCase);

  void fetchDictionaryById(int wordId) async {
    FetchDictionaryInputData input = FetchDictionaryInputData(wordId);
    await _fetchDictionaryUseCase.execute(input);
  }

  void fetchConjugacionById(int wordId) async {
    FetchConjugationInputData input = FetchConjugationInputData(wordId);
    await _fetchConjugationUseCase.execute(input);
  }
}
