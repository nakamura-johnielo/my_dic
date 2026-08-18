/// Catalog-owned part-of-speech taxonomy with stable persisted values.
enum CatalogPartOfSpeech {
  noun('名詞'),
  abbreviation('略語'),
  preposition('前置詞'),
  prefix('接辞'),
  adjective('形容詞'),
  verb('動詞'),
  adverb('副詞'),
  interjection('間投詞'),
  participle('分詞'),
  pronoun('代名詞'),
  conjunction('接続詞'),
  article('冠詞'),
  auxiliaryVerb('助動詞'),
  none('品詞ナシ');

  const CatalogPartOfSpeech(this.wireValue);

  final String wireValue;

  /// Keeps legacy fallback semantics for null, empty, and unknown DB values.
  static CatalogPartOfSpeech fromWireValue(String? value) {
    if (value == null || value.isEmpty) return CatalogPartOfSpeech.none;
    for (final partOfSpeech in values) {
      if (partOfSpeech.wireValue == value) return partOfSpeech;
    }
    return CatalogPartOfSpeech.none;
  }
}
