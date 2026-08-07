import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/core/application/usecase/fetch_dictionary/fetch_dictionary_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_dictionary/i_fetch_dictionary_use_case.dart';
import 'package:my_dic/core/application/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_use_case.dart';
import 'package:my_dic/core/application/usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/jpn_esp_state.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:logging/logging.dart';
import 'package:my_dic/router/navigator_service.dart';

class WordPageViewModel extends StateNotifier<WordPageState> {
  final IFetchJpnEspDictionaryUseCase _fetchDictionaryUseCase;
  final IFetchEspJpnDictionaryUseCase _fetchEspJpnDictionaryUsecase;
  final IFetchEspConjugationUseCase _fetchEspConjugacionUsecase;
  final AppNavigatorService _naviService;
  final _logger = Logger('WordPageViewModel');

  WordPageViewModel(
      this._fetchDictionaryUseCase,
      this._fetchEspJpnDictionaryUsecase,
      this._fetchEspConjugacionUsecase,
      this._naviService)
      : super(WordPageState(wordType: WordType.espJpn));

  Future<void> fetchJpnEspDictionaryById(int wordId) async {
    final previous = state.jpnEspDictionary.dataOrNull;
    state = state.copyWith(
      jpnEspDictionary: QueryState.loading(previousData: previous),
      wordType: WordType.jpnEsp,
    );
    FetchJpnEspDictionaryInputData input =
        FetchJpnEspDictionaryInputData(wordId);
    final result = await _fetchDictionaryUseCase.execute(input);

    result.when(
      success: (res) {
        state = state.copyWith(
          jpnEspDictionary:
              res.isEmpty ? QueryState.empty() : QueryState.data(res),
          wordType: WordType.jpnEsp,
        );
      },
      failure: (error) {
        state = state.copyWith(
          jpnEspDictionary: QueryState.failure(error, previousData: previous),
          wordType: WordType.jpnEsp,
        );
        _logger.warning('和西辞書の取得に失敗しました', error);
      },
    );
  }

  void goToQuiz(QuizGameRoute route) {
    _naviService.toFlashCard(route);
  }

  Future<void> fetchEspJpnItemsById(int wordId) async {
    final previousDictionary = state.espJpnDictionary.dataOrNull;
    final previousConjugations = state.conjugacions.dataOrNull;
    state = state.copyWith(
      espJpnDictionary: QueryState.loading(previousData: previousDictionary),
      conjugacions: QueryState.loading(previousData: previousConjugations),
      wordType: WordType.espJpn,
    );
    FetchDictionaryInputData input = FetchDictionaryInputData(wordId);
    final dicResult = await _fetchEspJpnDictionaryUsecase.execute(input);
    FetchConjugationInputData input2 = FetchConjugationInputData(wordId);
    final conjResult = await _fetchEspConjugacionUsecase.execute(input2);

    dicResult.when(
      success: (dic) {
        conjResult.when(
          success: (conj) {
            state = state.copyWith(
              espJpnDictionary:
                  dic.isEmpty ? QueryState.empty() : QueryState.data(dic),
              conjugacions:
                  conj == null ? QueryState.empty() : QueryState.data(conj),
              wordType: WordType.espJpn,
            );
          },
          failure: (error) {
            _logger.warning('活用形の取得に失敗しました', error);
            // 活用形の取得に失敗しても辞書データは表示する
            state = state.copyWith(
              espJpnDictionary: dic.isEmpty
                  ? QueryState.empty(
                      warnings: [
                        QueryWarning(source: 'conjugation', error: error),
                      ],
                    )
                  : QueryState.data(
                      dic,
                      warnings: [
                        QueryWarning(source: 'conjugation', error: error),
                      ],
                    ),
              conjugacions:
                  QueryState.failure(error, previousData: previousConjugations),
              wordType: WordType.espJpn,
            );
          },
        );
      },
      failure: (error) {
        _logger.warning('西和辞書の取得に失敗しました', error);
      },
    );
    dicResult.when(
      success: (_) {},
      failure: (error) {
        state = state.copyWith(
          espJpnDictionary:
              QueryState.failure(error, previousData: previousDictionary),
          conjugacions:
              QueryState.failure(error, previousData: previousConjugations),
          wordType: WordType.espJpn,
        );
      },
    );
  }

  Future<void> fetchEspJpnDictionaryById(int wordId) async {
    final previous = state.espJpnDictionary.dataOrNull;
    state = state.copyWith(
      espJpnDictionary: QueryState.loading(previousData: previous),
      wordType: WordType.espJpn,
    );
    FetchDictionaryInputData input = FetchDictionaryInputData(wordId);
    final result = await _fetchEspJpnDictionaryUsecase.execute(input);

    result.when(
      success: (res) {
        state = state.copyWith(
          espJpnDictionary:
              res.isEmpty ? QueryState.empty() : QueryState.data(res),
          wordType: WordType.espJpn,
        );
      },
      failure: (error) {
        _logger.warning('西和辞書の取得に失敗しました', error);
      },
    );
  }

  Future<void> fetchEspConjugacionById(int wordId) async {
    final previous = state.conjugacions.dataOrNull;
    state = state.copyWith(
      conjugacions: QueryState.loading(previousData: previous),
      wordType: WordType.espJpn,
    );
    FetchConjugationInputData input = FetchConjugationInputData(wordId);
    final result = await _fetchEspConjugacionUsecase.execute(input);

    result.when(
      success: (res) {
        state = state.copyWith(
          conjugacions: res == null ? QueryState.empty() : QueryState.data(res),
          wordType: WordType.espJpn,
        );
      },
      failure: (error) {
        _logger.warning('活用形の取得に失敗しました', error);
      },
    );
  }
}
