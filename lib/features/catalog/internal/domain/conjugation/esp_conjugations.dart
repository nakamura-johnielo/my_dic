import 'package:my_dic/features/catalog/internal/domain/conjugation/participles.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/tense_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';

class EspConjugacions {
  final int wordId;
  final Map<CatalogMoodTense, TenseConjugacion> conjugacions;
  final EspParticiples participles;

  const EspConjugacions({
    required this.wordId,
    required this.conjugacions,
    required this.participles,
  });

  EspConjugacions copyWith({
    int? wordId,
    Map<CatalogMoodTense, TenseConjugacion>? conjugacions,
    EspParticiples? participles,
  }) {
    return EspConjugacions(
      wordId: wordId ?? this.wordId,
      conjugacions: conjugacions ?? this.conjugacions,
      participles: participles ?? this.participles,
    );
  }
}
