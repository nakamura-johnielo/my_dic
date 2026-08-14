import 'package:my_dic/features/catalog/internal/domain/conjugation/participles.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/tense_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';

class EspJpnConjugation {
  final int wordId;
  final Map<CatalogMoodTense, TenseConjugation> conjugations;
  final EspParticiples participles;

  const EspJpnConjugation({
    required this.wordId,
    required this.conjugations,
    required this.participles,
  });

  EspJpnConjugation copyWith({
    int? wordId,
    Map<CatalogMoodTense, TenseConjugation>? conjugations,
    EspParticiples? participles,
  }) {
    return EspJpnConjugation(
      wordId: wordId ?? this.wordId,
      conjugations: conjugations ?? this.conjugations,
      participles: participles ?? this.participles,
    );
  }
}
