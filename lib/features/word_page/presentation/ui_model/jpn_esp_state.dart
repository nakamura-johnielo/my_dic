import 'package:flutter/material.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';

@immutable
class WordPageState {
  const WordPageState(
      {this.jpnEspDictionary = const QueryState.initial(),
      this.dictionaryCache,
      this.espJpnDictionary = const QueryState.initial(),
      this.conjugacions = const QueryState.initial(),
      required this.wordType});
  final Map<int, List<JpnEspDictionary>>? dictionaryCache;

  final WordType wordType;

  //====jpn-esp
  final QueryState<List<JpnEspDictionary>> jpnEspDictionary;

  //====esp-jpn
  final QueryState<List<EspJpnDictionary>> espJpnDictionary;
  final QueryState<EspConjugacions> conjugacions;

  WordPageState copyWith(
      {QueryState<List<JpnEspDictionary>>? jpnEspDictionary,
      Map<int, List<JpnEspDictionary>>? dictionaryCache,
      QueryState<List<EspJpnDictionary>>? espJpnDictionary,
      QueryState<EspConjugacions>? conjugacions,
      WordType? wordType}) {
    return WordPageState(
      jpnEspDictionary: jpnEspDictionary ?? this.jpnEspDictionary,
      dictionaryCache: dictionaryCache ?? this.dictionaryCache,
      espJpnDictionary: espJpnDictionary ?? this.espJpnDictionary,
      conjugacions: conjugacions ?? this.conjugacions,
      wordType: wordType ?? this.wordType,
    );
  }
}
