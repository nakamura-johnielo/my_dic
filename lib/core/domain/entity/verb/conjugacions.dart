import 'package:flutter/foundation.dart';
import 'package:my_dic/core/common/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/tense_conjugacion.dart';
import 'package:my_dic/core/domain/entity/verb/participles.dart';

//全部のconjを持ってる

@immutable
class EspConjugacions {
  //required int conjugacionId,
  final int wordId;
  final Map<MoodTense, TenseConjugacion> conjugacions;
  final EspParticiples participles;

  const EspConjugacions({
    required this.wordId,
    required this.conjugacions, required this.participles,
  });

  EspConjugacions copyWith({
    int? wordId,
    Map<MoodTense, TenseConjugacion>? conjugacions,
    EspParticiples? participles
  }) {
    return EspConjugacions(
      wordId: wordId ?? this.wordId,
      conjugacions: conjugacions ?? this.conjugacions, 
      participles:participles??this.participles,
    );
  }
}
