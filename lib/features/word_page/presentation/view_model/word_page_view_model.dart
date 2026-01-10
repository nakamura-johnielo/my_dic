import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/core/domain/usecase/fetch_dictionary/fetch_dictionary_input_data.dart';
import 'package:my_dic/core/domain/usecase/fetch_dictionary/i_fetch_dictionary_use_case.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_input_data.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_use_case.dart';
import 'package:my_dic/core/domain/usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/core/domain/usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_game_fragment.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/jpn_esp_state.dart';
import 'package:logging/logging.dart';
import 'package:my_dic/router/navigator_service.dart';

/// ViewModelをプロバイダーで提供
// final JpnEspWordPageViewModelProvider =
//     ChangeNotifierProvider((ref) => ref.read(jpnEspWordPageViewModelProvider));

class WordPageViewModel extends StateNotifier<WordPageState> {
  final IFetchJpnEspDictionaryUseCase _fetchDictionaryUseCase;
  final IFetchEspJpnDictionaryUseCase _fetchEspJpnDictionaryUsecase;
  final IFetchEspConjugationUseCase _fetchEspConjugacionUsecase;
  final AppNavigatorService _naviService;
  final _logger = Logger('WordPageViewModel');

  WordPageViewModel(this._fetchDictionaryUseCase,
      this._fetchEspJpnDictionaryUsecase, this._fetchEspConjugacionUsecase, this._naviService)
      : super(WordPageState(wordType: WordType.espJpn));

  Future<void> fetchJpnEspDictionaryById(int wordId) async {
    FetchJpnEspDictionaryInputData input =
        FetchJpnEspDictionaryInputData(wordId);
    final result = await _fetchDictionaryUseCase.execute(input);

    result.when(
      success: (res) {
        state =
            state.copyWith(jpnEspDictionary: res, wordType: WordType.jpnEsp);
      },
      failure: (error) {
        _logger.warning('和西辞書の取得に失敗しました', error);
      },
    );
  }

  void goToQuiz(QuizGameFragmentInput input) {
    _naviService.toFlashCard( input);
  }

  Future<void> fetchEspJpnItemsById(int wordId) async {
    FetchDictionaryInputData input = FetchDictionaryInputData(wordId);
    final dicResult = await _fetchEspJpnDictionaryUsecase.execute(input);
    FetchConjugationInputData input2 = FetchConjugationInputData(wordId);
    final conjResult = await _fetchEspConjugacionUsecase.execute(input2);

    dicResult.when(
      success: (dic) {
        conjResult.when(
          success: (conj) {
            state = state.copyWithNull(
                espJpnDictionary: dic,
                conjugacions: conj,
                wordType: WordType.espJpn);
          },
          failure: (error) {
            _logger.warning('活用形の取得に失敗しました', error);
            // 活用形の取得に失敗しても辞書データは表示する
            state = state.copyWithNull(
                espJpnDictionary: dic, wordType: WordType.espJpn);
          },
        );
      },
      failure: (error) {
        _logger.warning('西和辞書の取得に失敗しました', error);
      },
    );
  }

  Future<void> fetchEspJpnDictionaryById(int wordId) async {
    FetchDictionaryInputData input = FetchDictionaryInputData(wordId);
    final result = await _fetchEspJpnDictionaryUsecase.execute(input);

    result.when(
      success: (res) {
        state = state.copyWithNull(
            espJpnDictionary: res, wordType: WordType.espJpn);
      },
      failure: (error) {
        _logger.warning('西和辞書の取得に失敗しました', error);
      },
    );
  }

  Future<void> fetchEspConjugacionById(int wordId) async {
    FetchConjugationInputData input = FetchConjugationInputData(wordId);
    final result = await _fetchEspConjugacionUsecase.execute(input);

    result.when(
      success: (res) {
        state =
            state.copyWithNull(conjugacions: res, wordType: WordType.espJpn);
      },
      failure: (error) {
        _logger.warning('活用形の取得に失敗しました', error);
      },
    );
  }
}
