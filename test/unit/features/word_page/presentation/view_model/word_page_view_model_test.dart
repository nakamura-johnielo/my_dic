import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/application/usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/core/application/usecase/fetch_dictionary/fetch_dictionary_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_dictionary/i_fetch_dictionary_use_case.dart';
import 'package:my_dic/core/application/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_use_case.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/word_page_load_key.dart';
import 'package:my_dic/features/word_page/presentation/view_model/word_page_view_model.dart';

void main() {
  group('WordPageLoadKey', () {
    test('includes all query dimensions in equality', () {
      const base = WordPageLoadKey(
        wordId: 1,
        wordType: WordType.espJpn,
        hasConj: true,
      );

      expect(
          base,
          isNot(WordPageLoadKey(
            wordId: 1,
            wordType: WordType.espJpn,
            hasConj: false,
          )));
    });
  });

  group('WordPageViewModel.initialize', () {
    test('is idempotent for a Japanese-to-Spanish page', () async {
      final jpn = _JpnUseCase(Result.success([_jpnDictionary]));
      final esp = _EspUseCase(Result.success([_espDictionary]));
      final conjugation = _ConjugationUseCase(Result.success(null));
      final model = _model(jpn: jpn, esp: esp, conjugation: conjugation);
      const key = WordPageLoadKey(
        wordId: 3,
        wordType: WordType.jpnEsp,
        hasConj: false,
      );

      await Future.wait([model.initialize(key), model.initialize(key)]);

      expect(jpn.calls, 1);
      expect(esp.calls, 0);
      expect(conjugation.calls, 0);
      expect(model.state.jpnEspDictionary.dataOrNull, [_jpnDictionary]);
      model.dispose();
    });

    test('does not request conjugations when the key excludes them', () async {
      final esp = _EspUseCase(Result.success([_espDictionary]));
      final conjugation = _ConjugationUseCase(Result.success(null));
      final model = _model(esp: esp, conjugation: conjugation);

      await model.initialize(const WordPageLoadKey(
        wordId: 7,
        wordType: WordType.espJpn,
        hasConj: false,
      ));

      expect(esp.calls, 1);
      expect(conjugation.calls, 0);
      expect(model.state.espJpnDictionary.dataOrNull, [_espDictionary]);
      model.dispose();
    });

    test('requests dictionary and conjugations for an espJpn conjugation page',
        () async {
      final esp = _EspUseCase(Result.success([_espDictionary]));
      final conjugation = _ConjugationUseCase(Result.success(null));
      final model = _model(esp: esp, conjugation: conjugation);

      await model.initialize(const WordPageLoadKey(
        wordId: 7,
        wordType: WordType.espJpn,
        hasConj: true,
      ));

      expect(esp.calls, 1);
      expect(conjugation.calls, 1);
      expect(model.state.espJpnDictionary.isData, isTrue);
      expect(model.state.conjugacions.isEmpty, isTrue);
      model.dispose();
    });

    test('maps an empty dictionary result to QueryEmpty', () async {
      final model = _model(esp: _EspUseCase(Result.success([])));

      await model.initialize(const WordPageLoadKey(
        wordId: 9,
        wordType: WordType.espJpn,
        hasConj: false,
      ));

      expect(model.state.espJpnDictionary.isEmpty, isTrue);
      model.dispose();
    });

    test('maps a dictionary failure to QueryFailure', () async {
      final model = _model(
        esp: _EspUseCase(Result.failure(BusinessRuleError(message: 'failed'))),
      );

      await model.initialize(const WordPageLoadKey(
        wordId: 10,
        wordType: WordType.espJpn,
        hasConj: false,
      ));

      expect(model.state.espJpnDictionary.isFailure, isTrue);
      model.dispose();
    });

    test('keeps dictionary data with a warning when conjugations fail',
        () async {
      final error = BusinessRuleError(message: 'conjugation failed');
      final model = _model(
        esp: _EspUseCase(Result.success([_espDictionary])),
        conjugation: _ConjugationUseCase(Result.failure(error)),
      );

      await model.initialize(const WordPageLoadKey(
        wordId: 11,
        wordType: WordType.espJpn,
        hasConj: true,
      ));

      expect(model.state.espJpnDictionary.dataOrNull, [_espDictionary]);
      expect(model.state.espJpnDictionary.hasWarnings, isTrue);
      expect(model.state.conjugacions.isFailure, isTrue);
      model.dispose();
    });

    test('transitions from loading to dictionary data', () async {
      final esp = _DeferredEspUseCase();
      final model = _model(esp: esp);
      final loading = model.initialize(const WordPageLoadKey(
        wordId: 8,
        wordType: WordType.espJpn,
        hasConj: false,
      ));

      expect(model.state.espJpnDictionary.isInitialLoading, isTrue);
      esp.complete(Result.success([_espDictionary]));
      await loading;

      expect(model.state.espJpnDictionary.dataOrNull, [_espDictionary]);
      model.dispose();
    });

    test('ignores a result that completes after disposal', () async {
      final esp = _DeferredEspUseCase();
      final model = _model(esp: esp);
      final loading = model.initialize(const WordPageLoadKey(
        wordId: 8,
        wordType: WordType.espJpn,
        hasConj: false,
      ));

      model.dispose();
      esp.complete(Result.success([_espDictionary]));

      await loading;
      expect(esp.calls, 1);
    });
  });
}

const _espDictionary = EspJpnDictionary(dictionaryId: 1, word: 'hablar');
const _jpnDictionary = JpnEspDictionary(id: 1, wordId: 3, word: '話す');

WordPageViewModel _model({
  _JpnUseCase? jpn,
  IFetchEspJpnDictionaryUseCase? esp,
  _ConjugationUseCase? conjugation,
}) =>
    WordPageViewModel(
      jpn ?? _JpnUseCase(Result.success([])),
      esp ?? _EspUseCase(Result.success([])),
      conjugation ?? _ConjugationUseCase(Result.success(null)),
    );

class _JpnUseCase implements IFetchJpnEspDictionaryUseCase {
  _JpnUseCase(this.result);
  final Result<List<JpnEspDictionary>> result;
  int calls = 0;

  @override
  Future<Result<List<JpnEspDictionary>>> execute(
      FetchJpnEspDictionaryInputData input) async {
    calls++;
    return result;
  }
}

class _EspUseCase implements IFetchEspJpnDictionaryUseCase {
  _EspUseCase(this.result);
  final Result<List<EspJpnDictionary>> result;
  int calls = 0;

  @override
  Future<Result<List<EspJpnDictionary>>> execute(
      FetchDictionaryInputData input) async {
    calls++;
    return result;
  }
}

class _DeferredEspUseCase implements IFetchEspJpnDictionaryUseCase {
  final _result = Completer<Result<List<EspJpnDictionary>>>();
  int calls = 0;

  void complete(Result<List<EspJpnDictionary>> result) =>
      _result.complete(result);

  @override
  Future<Result<List<EspJpnDictionary>>> execute(
      FetchDictionaryInputData input) {
    calls++;
    return _result.future;
  }
}

class _ConjugationUseCase implements IFetchEspConjugationUseCase {
  _ConjugationUseCase(this.result);
  final Result<EspConjugacions?> result;
  int calls = 0;

  @override
  Future<Result<EspConjugacions?>> execute(
      FetchConjugationInputData input) async {
    calls++;
    return result;
  }
}
