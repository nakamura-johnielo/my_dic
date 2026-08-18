/// Immutable Spanish-to-Japanese dictionary entry exposed by Catalog.
final class EspJpnEntry {
  EspJpnEntry({
    required this.dictionaryId,
    required this.word,
    this.headword,
    this.content,
    this.origin,
    List<EspJpnExample> examples = const [],
    List<EspJpnIdiom> idioms = const [],
    List<CatalogSupplement> supplements = const [],
  })  : examples = List.unmodifiable(examples),
        idioms = List.unmodifiable(idioms),
        supplements = List.unmodifiable(supplements);

  final int dictionaryId;
  final String word;
  final String? headword;
  final String? content;
  final String? origin;
  final List<EspJpnExample> examples;
  final List<EspJpnIdiom> idioms;
  final List<CatalogSupplement> supplements;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EspJpnEntry &&
          dictionaryId == other.dictionaryId &&
          word == other.word &&
          headword == other.headword &&
          content == other.content &&
          origin == other.origin &&
          _listEquals(examples, other.examples) &&
          _listEquals(idioms, other.idioms) &&
          _listEquals(supplements, other.supplements);

  @override
  int get hashCode => Object.hash(
        dictionaryId,
        word,
        headword,
        content,
        origin,
        Object.hashAll(examples),
        Object.hashAll(idioms),
        Object.hashAll(supplements),
      );
}

final class EspJpnExample {
  const EspJpnExample({
    required this.exampleId,
    required this.japanese,
    required this.espanol,
  });

  final int exampleId;
  final String japanese;
  final String espanol;

  @override
  bool operator ==(Object other) =>
      other is EspJpnExample &&
      exampleId == other.exampleId &&
      japanese == other.japanese &&
      espanol == other.espanol;

  @override
  int get hashCode => Object.hash(exampleId, japanese, espanol);
}

final class EspJpnIdiom {
  const EspJpnIdiom({
    required this.idiomId,
    required this.idiom,
    required this.description,
  });

  final int idiomId;
  final String idiom;
  final String description;

  @override
  bool operator ==(Object other) =>
      other is EspJpnIdiom &&
      idiomId == other.idiomId &&
      idiom == other.idiom &&
      description == other.description;

  @override
  int get hashCode => Object.hash(idiomId, idiom, description);
}

final class CatalogSupplement {
  const CatalogSupplement({
    required this.supplementId,
    required this.supplement,
  });

  final int supplementId;
  final String supplement;

  @override
  bool operator ==(Object other) =>
      other is CatalogSupplement &&
      supplementId == other.supplementId &&
      supplement == other.supplement;

  @override
  int get hashCode => Object.hash(supplementId, supplement);
}

bool _listEquals<T>(List<T> first, List<T> second) {
  if (identical(first, second)) return true;
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}
