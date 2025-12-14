import 'package:flutter/foundation.dart';
import 'package:my_dic/Constants/Enums/mood_tense.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/tense_conjugacion.dart';

//全部のconjを持ってる

@immutable
class Conjugacions {
  //required int conjugacionId,
  final int wordId;
  final Map<MoodTense, TenseConjugacion> conjugacions;

  const Conjugacions({
    required this.wordId,
    required this.conjugacions,
  });

  Conjugacions copyWith({
    int? wordId,
    Map<MoodTense, TenseConjugacion>? conjugacions,
  }) {
    return Conjugacions(
      wordId: wordId ?? this.wordId,
      conjugacions: conjugacions ?? this.conjugacions,
    );
  }
}
