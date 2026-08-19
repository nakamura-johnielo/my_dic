/// 安定した永続化値を持つ、Catalog 所有の品詞分類。
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

  /// null、空、および未知の DB 値に対するレガシーのフォールバック動作を維持する。
  static CatalogPartOfSpeech fromWireValue(String? value) {
    if (value == null || value.isEmpty) return CatalogPartOfSpeech.none;
    for (final partOfSpeech in values) {
      if (partOfSpeech.wireValue == value) return partOfSpeech;
    }
    return CatalogPartOfSpeech.none;
  }
}
