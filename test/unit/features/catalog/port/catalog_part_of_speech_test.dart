import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';

void main() {
  test('part-of-speech wire values remain compatible with the Catalog DB', () {
    expect(
      {
        for (final value in CatalogPartOfSpeech.values)
          value.name: value.wireValue
      },
      {
        'noun': '名詞',
        'abbreviation': '略語',
        'preposition': '前置詞',
        'prefix': '接辞',
        'adjective': '形容詞',
        'verb': '動詞',
        'adverb': '副詞',
        'interjection': '間投詞',
        'participle': '分詞',
        'pronoun': '代名詞',
        'conjunction': '接続詞',
        'article': '冠詞',
        'auxiliaryVerb': '助動詞',
        'none': '品詞ナシ',
      },
    );
  });

  test('maps every known value and safely falls back for unknown DB values',
      () {
    for (final value in CatalogPartOfSpeech.values) {
      expect(CatalogPartOfSpeech.fromWireValue(value.wireValue), value);
    }
    expect(CatalogPartOfSpeech.fromWireValue('unexpected'),
        CatalogPartOfSpeech.none);
    expect(CatalogPartOfSpeech.fromWireValue(null), CatalogPartOfSpeech.none);
    expect(CatalogPartOfSpeech.fromWireValue(''), CatalogPartOfSpeech.none);
  });
}
