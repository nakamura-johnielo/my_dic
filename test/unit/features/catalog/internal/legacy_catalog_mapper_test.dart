import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart'
    as legacy;
import 'package:my_dic/core/domain/entity/dictionary/sub/example/impl/esp_jpn_example.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/idiom/impl/idiom.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/supplement.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/example/jpn_esp_example.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart'
    as legacy;
import 'package:my_dic/core/domain/entity/verb/conjugacion/tense_conjugacion.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/core/domain/entity/verb/participles.dart';
import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/legacy_catalog_mapper.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';

void main() {
  const espWord = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 71);

  test('maps every EspJpn field and normalizes null collections', () {
    const source = legacy.EspJpnDictionary(
      dictionaryId: 12,
      word: 'hablar',
      headword: 'hablar',
      content: '<p>speak</p>',
      origin: 'Latin',
      examples: [
        EspJpnExample(exampleId: 1, japanese: '話す', espanol: 'hablar')
      ],
      idioms: [
        Idiom(idiomId: 2, idiom: 'hablar claro', description: 'plainly')
      ],
      supplements: [Supplement(supplementId: 3, supplement: 'grammar')],
    );

    final entry =
        LegacyCatalogMapper.espJpnDetail(espWord, [source]).entries.single;
    expect(entry.dictionaryId, 12);
    expect(entry.word, 'hablar');
    expect(entry.headword, 'hablar');
    expect(entry.content, '<p>speak</p>');
    expect(entry.origin, 'Latin');
    expect(entry.examples.single.japanese, '話す');
    expect(entry.idioms.single.description, 'plainly');
    expect(entry.supplements.single.supplement, 'grammar');

    const emptySource =
        legacy.EspJpnDictionary(dictionaryId: 13, word: 'decir');
    final empty = LegacyCatalogMapper.espJpnEntry(emptySource);
    expect(empty.examples, isEmpty);
    expect(empty.idioms, isEmpty);
    expect(empty.supplements, isEmpty);
    expect(() => empty.examples.add(entry.examples.single),
        throwsUnsupportedError);
  });

  test('maps every JpnEsp field and normalizes null examples', () {
    const word = CatalogWordRef(catalogId: CatalogId.jpnEspMain, wordId: 19);
    const source = legacy.JpnEspDictionary(
      id: 5,
      wordId: 19,
      word: '話す',
      headword: 'はなす',
      content: '<p>hablar</p>',
      examples: [
        JpnEspExampleWith(
          exampleId: 4,
          japanese: '私は話す',
          espanol: 'Yo hablo',
          espanolHtml: '<b>Yo hablo</b>',
        ),
      ],
    );

    final entry =
        LegacyCatalogMapper.jpnEspDetail(word, [source]).entries.single;
    expect(entry.dictionaryId, 5);
    expect(entry.wordId, 19);
    expect(entry.word, '話す');
    expect(entry.headword, 'はなす');
    expect(entry.content, '<p>hablar</p>');
    expect(entry.examples.single.espanolHtml, '<b>Yo hablo</b>');
    expect(
        LegacyCatalogMapper.jpnEspEntry(
          const legacy.JpnEspDictionary(id: 6, wordId: 20, word: '言う'),
        ).examples,
        isEmpty);
  });

  test('maps conjugation moods, all subjects, and participles', () {
    const tense = TenseConjugacion(
      yo: 'hablo',
      tu: 'hablas',
      el: 'habla',
      nosotros: 'hablamos',
      vosotros: 'habláis',
      ellos: 'hablan',
    );
    const source = EspConjugacions(
      wordId: 71,
      conjugacions: {MoodTense.indicativePresent: tense},
      participles: EspParticiples(present: 'hablando', past: 'hablado'),
    );

    final result = LegacyCatalogMapper.conjugation(espWord, source);
    final forms = result.conjugations[CatalogMoodTense.indicativePresent]!;
    expect(result.word, espWord);
    expect(forms[CatalogSubject.yo], 'hablo');
    expect(forms[CatalogSubject.vosotros], 'habláis');
    expect(forms[CatalogSubject.ellos], 'hablan');
    expect(result.participles.present, 'hablando');
    expect(result.participles.past, 'hablado');
  });
}
