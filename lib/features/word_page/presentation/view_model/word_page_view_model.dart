import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/common/enums/word/word_type.dart';
import 'package:my_dic/core/domain/usecase/fetch_dictionary/fetch_dictionary_input_data.dart';
import 'package:my_dic/core/domain/usecase/fetch_dictionary/i_fetch_dictionary_use_case.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_input_data.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_use_case.dart';
import 'package:my_dic/core/domain/usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/core/domain/usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/jpn_esp_state.dart';

/// ViewModelをプロバイダーで提供
// final JpnEspWordPageViewModelProvider =
//     ChangeNotifierProvider((ref) => ref.read(jpnEspWordPageViewModelProvider));

class WordPageViewModel extends StateNotifier<WordPageState> {
  final IFetchJpnEspDictionaryUseCase _fetchDictionaryUseCase;
  final IFetchEspJpnDictionaryUseCase _fetchEspJpnDictionaryUsecase;
  final IFetchEspConjugationUseCase _fetchEspConjugacionUsecase;

  WordPageViewModel(this._fetchDictionaryUseCase,
      this._fetchEspJpnDictionaryUsecase, this._fetchEspConjugacionUsecase)
      : super(WordPageState(wordType: WordType.espJpn));

  Future<void> fetchJpnEspDictionaryById(int wordId) async {
    FetchJpnEspDictionaryInputData input =
        FetchJpnEspDictionaryInputData(wordId);
    final res = await _fetchDictionaryUseCase.execute(input);
    state = state.copyWith(jpnEspDictionary: res, wordType: WordType.jpnEsp);
  }

  Future<void> fetchEspJpnItemsById(int wordId)async{
    FetchDictionaryInputData input = FetchDictionaryInputData(wordId);
    final dic = await _fetchEspJpnDictionaryUsecase.execute(input);
    FetchConjugationInputData input2 = FetchConjugationInputData(wordId);
    final conj = await _fetchEspConjugacionUsecase.execute(input2);
    state=state.copyWithNull(espJpnDictionary: dic,conjugacions: conj,wordType: WordType.espJpn);
  }

  Future<void> fetchEspJpnDictionaryById(int wordId) async {
    FetchDictionaryInputData input = FetchDictionaryInputData(wordId);
    final res = await _fetchEspJpnDictionaryUsecase.execute(input);
    state = state.copyWithNull(espJpnDictionary: res,wordType: WordType.espJpn);
  }

  Future<void> fetchEspConjugacionById(int wordId) async {
    FetchConjugationInputData input = FetchConjugationInputData(wordId);
    final res = await _fetchEspConjugacionUsecase.execute(input);
    state = state.copyWithNull(conjugacions: res,wordType: WordType.espJpn);
  }
}
