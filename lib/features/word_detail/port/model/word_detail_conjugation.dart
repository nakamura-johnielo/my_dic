import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;

/// Immutable conjugation data owned by the WordDetail contract.
final class WordDetailConjugation {
  WordDetailConjugation({
    required this.word,
    required Map<WordDetailMoodTense, WordDetailTenseConjugation> conjugations,
    required this.participles,
  }) : conjugations = Map.unmodifiable(conjugations);

  final CatalogWordRef word;
  final Map<WordDetailMoodTense, WordDetailTenseConjugation> conjugations;
  final WordDetailParticiples participles;
}

enum WordDetailMoodTense {
  participlePresent,
  participlePast,
  indicativePresent,
  indicativePreterite,
  indicativeImperfect,
  indicativeFuture,
  indicativeConditional,
  imperative,
  subjunctivePresent,
  subjunctivePast,
}

enum WordDetailSubject { yo, tu, el, nosotros, vosotros, ellos }

final class WordDetailTenseConjugation {
  WordDetailTenseConjugation({
    required Map<WordDetailSubject, String> forms,
  }) : forms = Map.unmodifiable(forms);

  final Map<WordDetailSubject, String> forms;

  String? operator [](WordDetailSubject subject) => forms[subject];
}

final class WordDetailParticiples {
  const WordDetailParticiples({required this.present, required this.past});

  final String present;
  final String past;
}
