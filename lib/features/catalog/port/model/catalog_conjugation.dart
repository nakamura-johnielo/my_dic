import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

/// Immutable conjugation data for a Spanish Catalog word.
final class CatalogConjugation {
  CatalogConjugation({
    required this.word,
    required Map<CatalogMoodTense, CatalogTenseConjugation> conjugations,
    required this.participles,
  }) : conjugations = Map.unmodifiable(conjugations);

  final CatalogWordRef word;
  final Map<CatalogMoodTense, CatalogTenseConjugation> conjugations;
  final CatalogParticiples participles;

  @override
  bool operator ==(Object other) =>
      other is CatalogConjugation &&
      word == other.word &&
      _mapEquals(conjugations, other.conjugations) &&
      participles == other.participles;

  @override
  int get hashCode => Object.hash(word, _mapHash(conjugations), participles);
}

enum CatalogMoodTense {
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

enum CatalogSubject { yo, tu, el, nosotros, vosotros, ellos }

final class CatalogTenseConjugation {
  CatalogTenseConjugation({
    required Map<CatalogSubject, String> forms,
  }) : forms = Map.unmodifiable(forms);

  final Map<CatalogSubject, String> forms;

  String? operator [](CatalogSubject subject) => forms[subject];

  @override
  bool operator ==(Object other) =>
      other is CatalogTenseConjugation && _mapEquals(forms, other.forms);

  @override
  int get hashCode => _mapHash(forms);
}

final class CatalogParticiples {
  const CatalogParticiples({required this.present, required this.past});

  final String present;
  final String past;

  @override
  bool operator ==(Object other) =>
      other is CatalogParticiples &&
      present == other.present &&
      past == other.past;

  @override
  int get hashCode => Object.hash(present, past);
}

bool _mapEquals<K, V>(Map<K, V> first, Map<K, V> second) {
  if (identical(first, second)) return true;
  if (first.length != second.length) return false;
  for (final entry in first.entries) {
    if (second[entry.key] != entry.value) return false;
  }
  return true;
}

int _mapHash<K, V>(Map<K, V> map) => Object.hashAllUnordered(
    map.entries.map((entry) => Object.hash(entry.key, entry.value)));
