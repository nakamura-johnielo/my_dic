import 'package:flutter/material.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';

@immutable
class WordPageState {
  WordPageState(
      {this.jpnEspDictionary,
      this.dictionaryCache,
      this.espJpnDictionary,
      this.conjugacions,
      required this.wordType});
  final Map<int, List<JpnEspDictionary>>? dictionaryCache;

  final WordType wordType;

  //====jpn-esp
  final List<JpnEspDictionary>? jpnEspDictionary;

  //====esp-jpn
  final List<EspJpnDictionary>? espJpnDictionary;
  final EspConjugacions? conjugacions;

  WordPageState copyWith(
      {List<JpnEspDictionary>? jpnEspDictionary,
      Map<int, List<JpnEspDictionary>>? dictionaryCache,
      List<EspJpnDictionary>? espJpnDictionary,
      EspConjugacions? conjugacions,
      WordType? wordType}) {
    return WordPageState(
      jpnEspDictionary: jpnEspDictionary ?? this.jpnEspDictionary,
      dictionaryCache: dictionaryCache ?? this.dictionaryCache,
      espJpnDictionary: espJpnDictionary ?? this.espJpnDictionary,
      conjugacions: conjugacions ?? this.conjugacions,
      wordType: wordType ?? this.wordType,
    );
  }

  WordPageState copyWithNull(
      {List<JpnEspDictionary>? jpnEspDictionary,
      Map<int, List<JpnEspDictionary>>? dictionaryCache,
      List<EspJpnDictionary>? espJpnDictionary,
      EspConjugacions? conjugacions,
      WordType? wordType}) {
    return WordPageState(
        jpnEspDictionary: jpnEspDictionary,
        dictionaryCache: dictionaryCache,
        espJpnDictionary: espJpnDictionary,
        conjugacions: conjugacions,
        wordType: wordType ?? this.wordType);
  }
}
