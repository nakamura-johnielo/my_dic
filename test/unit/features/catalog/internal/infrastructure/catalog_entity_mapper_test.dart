import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/esp_conjugations.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/participles.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/tense_conjugation.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/esp_jpn_dictionary.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/jpn_esp_dictionary.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/supplement.dart';
import 'package:my_dic/features/catalog/internal/domain/example/esp_jpn_example.dart';
import 'package:my_dic/features/catalog/internal/domain/example/jpn_esp_example.dart';
import 'package:my_dic/features/catalog/internal/domain/idiom/idiom.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_entity_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_drift_mapper.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);

  test('maps every EspJpn field and normalizes immutable collections', () {
    const dictionaries = [
      EspJpnDictionary(
        dictionaryId: 1,
        word: 'hablar',
        headword: 'hablar',
        content: '<p>speak</p>',
        origin: 'Latin',
        examples: [
          EspJpnExample(exampleId: 2, japanese: '話す', espanol: 'hablar'),
        ],
        idioms: [
          Idiom(idiomId: 3, idiom: 'hablar claro', description: 'plainly'),
        ],
        supplements: [
          Supplement(supplementId: 4, supplement: 'grammar'),
        ],
      ),
    ];

    final entry =
        CatalogEntityMapper.espJpnDetail(word, dictionaries).entries.single;
    expect(entry.dictionaryId, 1);
    expect(entry.word, 'hablar');
    expect(entry.headword, 'hablar');
    expect(entry.content, '<p>speak</p>');
    expect(entry.origin, 'Latin');
    expect(entry.examples.single.japanese, '話す');
    expect(entry.idioms.single.description, 'plainly');
    expect(entry.supplements.single.supplement, 'grammar');
    expect(() => entry.examples.clear(), throwsUnsupportedError);

    final empty = CatalogEntityMapper.espJpnDetail(
      word,
      const [EspJpnDictionary(dictionaryId: 5, word: 'decir')],
    ).entries.single;
    expect(empty.examples, isEmpty);
    expect(empty.idioms, isEmpty);
    expect(empty.supplements, isEmpty);
  });

  test('maps a Jpn-Esp catalog row to its dictionary identity and headword',
      () {
    final word = CatalogDriftMapper.jpnEspWord(
      const JpnEspWordTableData(wordId: 19, word: '家'),
    );

    expect(word.id, 19);
    expect(word.word, '家');
  });

  test('maps every JpnEsp field and normalizes null examples', () {
    const jpnWord = CatalogWordRef(catalogId: CatalogId.jpnEspMain, wordId: 19);
    final entry = CatalogEntityMapper.jpnEspDetail(
      jpnWord,
      const [
        JpnEspDictionary(
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
        ),
      ],
    ).entries.single;
    expect(entry.dictionaryId, 5);
    expect(entry.wordId, 19);
    expect(entry.word, '話す');
    expect(entry.headword, 'はなす');
    expect(entry.content, '<p>hablar</p>');
    expect(entry.examples.single.espanolHtml, '<b>Yo hablo</b>');

    final empty = CatalogEntityMapper.jpnEspDetail(
      jpnWord,
      const [JpnEspDictionary(id: 6, wordId: 19, word: '言う')],
    ).entries.single;
    expect(empty.examples, isEmpty);
  });

  test('maps conjugation moods, all subjects, and participles immutably', () {
    const entity = EspJpnConjugation(
      wordId: 7,
      conjugations: {
        CatalogMoodTense.indicativePresent: TenseConjugation(
          yo: 'hablo',
          tu: 'hablas',
          el: 'habla',
          nosotros: 'hablamos',
          vosotros: 'habláis',
          ellos: 'hablan',
        ),
      },
      participles: EspParticiples(present: 'hablando', past: 'hablado'),
    );

    final dto = CatalogEntityMapper.conjugation(word, entity);
    final forms = dto.conjugations[CatalogMoodTense.indicativePresent]!;
    expect(dto.word, word);
    expect(forms[CatalogSubject.yo], 'hablo');
    expect(forms[CatalogSubject.vosotros], 'habláis');
    expect(forms[CatalogSubject.ellos], 'hablan');
    expect(dto.participles.present, 'hablando');
    expect(dto.participles.past, 'hablado');
    expect(() => dto.conjugations.clear(), throwsUnsupportedError);
    expect(() => forms.forms.clear(), throwsUnsupportedError);
  });
}
