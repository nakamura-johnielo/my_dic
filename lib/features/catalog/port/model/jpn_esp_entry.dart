/// Immutable Japanese-to-Spanish dictionary entry exposed by Catalog.
final class JpnEspEntry {
  JpnEspEntry({
    required this.dictionaryId,
    required this.wordId,
    required this.word,
    this.headword,
    this.content,
    List<JpnEspExample> examples = const [],
  }) : examples = List.unmodifiable(examples);

  final int dictionaryId;
  final int wordId;
  final String word;
  final String? headword;
  final String? content;
  final List<JpnEspExample> examples;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JpnEspEntry &&
          dictionaryId == other.dictionaryId &&
          wordId == other.wordId &&
          word == other.word &&
          headword == other.headword &&
          content == other.content &&
          _listEquals(examples, other.examples);

  @override
  int get hashCode => Object.hash(
        dictionaryId,
        wordId,
        word,
        headword,
        content,
        Object.hashAll(examples),
      );
}

final class JpnEspExample {
  const JpnEspExample({
    required this.exampleId,
    required this.japanese,
    required this.espanol,
    required this.espanolHtml,
  });

  final int exampleId;
  final String japanese;
  final String espanol;
  final String espanolHtml;

  @override
  bool operator ==(Object other) =>
      other is JpnEspExample &&
      exampleId == other.exampleId &&
      japanese == other.japanese &&
      espanol == other.espanol &&
      espanolHtml == other.espanolHtml;

  @override
  int get hashCode => Object.hash(exampleId, japanese, espanol, espanolHtml);
}

bool _listEquals<T>(List<T> first, List<T> second) {
  if (identical(first, second)) return true;
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}
