import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';

/// Immutable, provider-neutral inputs required to render a Quiz game.
final class QuizGameData {
  QuizGameData({
    required this.conjugation,
    required Map<String, String> englishGuide,
    required Map<String, Map<String, String>> beConjugation,
    required Map<String, String> englishConjugation,
  })  : englishGuide = Map.unmodifiable(englishGuide),
        beConjugation = Map<String, Map<String, String>>.unmodifiable({
          for (final entry in beConjugation.entries)
            entry.key: Map<String, String>.unmodifiable(entry.value),
        }),
        englishConjugation = Map.unmodifiable(englishConjugation);

  final CatalogConjugation conjugation;
  final Map<String, String> englishGuide;
  final Map<String, Map<String, String>> beConjugation;
  final Map<String, String> englishConjugation;

  @override
  bool operator ==(Object other) =>
      other is QuizGameData &&
      conjugation == other.conjugation &&
      _mapEquals(englishGuide, other.englishGuide) &&
      _nestedMapEquals(beConjugation, other.beConjugation) &&
      _mapEquals(englishConjugation, other.englishConjugation);

  @override
  int get hashCode => Object.hash(
        conjugation,
        _mapHash(englishGuide),
        Object.hashAllUnordered(
          beConjugation.entries.map(
            (entry) => Object.hash(entry.key, _mapHash(entry.value)),
          ),
        ),
        _mapHash(englishConjugation),
      );
}

bool _mapEquals<K, V>(Map<K, V> first, Map<K, V> second) {
  if (first.length != second.length) return false;
  for (final entry in first.entries) {
    if (second[entry.key] != entry.value) return false;
  }
  return true;
}

bool _nestedMapEquals(
  Map<String, Map<String, String>> first,
  Map<String, Map<String, String>> second,
) {
  if (first.length != second.length) return false;
  for (final entry in first.entries) {
    final value = second[entry.key];
    if (value == null || !_mapEquals(entry.value, value)) return false;
  }
  return true;
}

int _mapHash<K, V>(Map<K, V> map) => Object.hashAllUnordered(
      map.entries.map((entry) => Object.hash(entry.key, entry.value)),
    );
