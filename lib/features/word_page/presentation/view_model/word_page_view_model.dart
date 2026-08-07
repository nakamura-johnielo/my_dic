import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/core/application/usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/core/application/usecase/fetch_dictionary/fetch_dictionary_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_dictionary/i_fetch_dictionary_use_case.dart';
import 'package:my_dic/core/application/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_use_case.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/jpn_esp_state.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/word_page_load_key.dart';
import 'package:my_dic/router/navigator_service.dart';

class WordPageViewModel extends StateNotifier<WordPageState> {
  WordPageViewModel(
    this._fetchJpnEspDictionaryUseCase,
    this._fetchEspJpnDictionaryUseCase,
    this._fetchEspConjugationUseCase,
    this._navigator,
  ) : super(WordPageState(wordType: WordType.espJpn));

  final IFetchJpnEspDictionaryUseCase _fetchJpnEspDictionaryUseCase;
  final IFetchEspJpnDictionaryUseCase _fetchEspJpnDictionaryUseCase;
  final IFetchEspConjugationUseCase _fetchEspConjugationUseCase;
  final AppNavigatorService _navigator;
  final _logger = Logger('WordPageViewModel');

  Future<void>? _initialization;
  var _generation = 0;

  /// Starts the single request owned by this provider instance.
  Future<void> initialize(WordPageLoadKey key) =>
      _initialization ??= _load(key, ++_generation);

  Future<void> _load(WordPageLoadKey key, int generation) async {
    switch (key.wordType) {
      case WordType.jpnEsp:
        await _loadJpnEspDictionary(key.wordId, generation);
        return;
      case WordType.espJpn:
        await _loadEspJpnItems(key, generation);
        return;
      case WordType.espEng:
      case WordType.engEsp:
        return;
    }
  }

  Future<void> _loadJpnEspDictionary(int wordId, int generation) async {
    final previous = state.jpnEspDictionary.dataOrNull;
    _setState(
        generation,
        state.copyWith(
          jpnEspDictionary: QueryState.loading(previousData: previous),
          wordType: WordType.jpnEsp,
        ));

    final result = await _fetchJpnEspDictionaryUseCase
        .execute(FetchJpnEspDictionaryInputData(wordId));
    if (!_isCurrent(generation)) return;

    result.when(
      success: (dictionaries) => _setState(
          generation,
          state.copyWith(
            jpnEspDictionary: dictionaries.isEmpty
                ? QueryState.empty()
                : QueryState.data(dictionaries),
            wordType: WordType.jpnEsp,
          )),
      failure: (error) {
        _logger.warning('Failed to fetch Japanese-Spanish dictionary', error);
        _setState(
            generation,
            state.copyWith(
              jpnEspDictionary:
                  QueryState.failure(error, previousData: previous),
              wordType: WordType.jpnEsp,
            ));
      },
    );
  }

  Future<void> _loadEspJpnItems(WordPageLoadKey key, int generation) async {
    final previousDictionary = state.espJpnDictionary.dataOrNull;
    final previousConjugations = state.conjugacions.dataOrNull;
    _setState(
        generation,
        state.copyWith(
          espJpnDictionary:
              QueryState.loading(previousData: previousDictionary),
          conjugacions: key.hasConj
              ? QueryState.loading(previousData: previousConjugations)
              : state.conjugacions,
          wordType: WordType.espJpn,
        ));

    final dictionaryFuture = _fetchEspJpnDictionaryUseCase
        .execute(FetchDictionaryInputData(key.wordId));
    final conjugationFuture = key.hasConj
        ? _fetchEspConjugationUseCase
            .execute(FetchConjugationInputData(key.wordId))
        : null;
    final dictionaryResult = await dictionaryFuture;
    final conjugationResult =
        conjugationFuture == null ? null : await conjugationFuture;
    if (!_isCurrent(generation)) return;

    dictionaryResult.when(
      success: (dictionaries) {
        if (conjugationResult == null) {
          _setDictionaryResult(generation, dictionaries);
          return;
        }
        conjugationResult.when(
          success: (conjugations) => _setState(
              generation,
              state.copyWith(
                espJpnDictionary: dictionaries.isEmpty
                    ? QueryState.empty()
                    : QueryState.data(dictionaries),
                conjugacions: conjugations == null
                    ? QueryState.empty()
                    : QueryState.data(conjugations),
                wordType: WordType.espJpn,
              )),
          failure: (error) {
            _logger.warning('Failed to fetch conjugations', error);
            _setState(
                generation,
                state.copyWith(
                  espJpnDictionary: dictionaries.isEmpty
                      ? QueryState.empty(warnings: [
                          QueryWarning(source: 'conjugation', error: error),
                        ])
                      : QueryState.data(dictionaries, warnings: [
                          QueryWarning(source: 'conjugation', error: error),
                        ]),
                  conjugacions: QueryState.failure(error,
                      previousData: previousConjugations),
                  wordType: WordType.espJpn,
                ));
          },
        );
      },
      failure: (error) {
        _logger.warning('Failed to fetch Spanish-Japanese dictionary', error);
        _setState(
            generation,
            state.copyWith(
              espJpnDictionary:
                  QueryState.failure(error, previousData: previousDictionary),
              conjugacions: key.hasConj
                  ? QueryState.failure(error,
                      previousData: previousConjugations)
                  : state.conjugacions,
              wordType: WordType.espJpn,
            ));
      },
    );
  }

  void _setDictionaryResult(
      int generation, List<EspJpnDictionary> dictionaries) {
    _setState(
        generation,
        state.copyWith(
          espJpnDictionary: dictionaries.isEmpty
              ? QueryState.empty()
              : QueryState.data(dictionaries),
          wordType: WordType.espJpn,
        ));
  }

  bool _isCurrent(int generation) => mounted && generation == _generation;

  void _setState(int generation, WordPageState next) {
    if (_isCurrent(generation)) state = next;
  }

  void goToQuiz(QuizGameRoute route) => _navigator.toFlashCard(route);

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }
}
