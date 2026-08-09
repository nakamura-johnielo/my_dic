import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/esp_conjugations.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/participles.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/tense_conjugation.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/esp_jpn_dictionary.dart';
import 'package:my_dic/features/catalog/internal/domain/example/esp_jpn_example.dart';
import 'package:my_dic/features/catalog/internal/domain/word/esp_jpn_word.dart';
import 'package:my_dic/features/catalog/internal/domain/word/jpn_esp_word.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';

void main() {
  test('Esp-Jpn word uses the Catalog-owned part-of-speech taxonomy', () {
    const word = EspJpnWord(
      wordId: 7,
      word: 'hablar',
      partOfSpeech: [CatalogPartOfSpeech.verb],
    );

    expect(word.hasVerb(), isTrue);
    expect(word.copyWith(word: 'comer').partOfSpeech, same(word.partOfSpeech));
  });

  test('Jpn-Esp word carries only Catalog identity and headword', () {
    const word = JpnEspWord(id: 19, word: '家');

    final updated = word.copyWith(id: 20);
    expect(updated.id, 20);
    expect(updated.word, '家');
  });

  test('dictionary copy preserves nullable collections and their ordering', () {
    const examples = [
      EspJpnExample(exampleId: 2, japanese: '二', espanol: 'dos'),
      EspJpnExample(exampleId: 1, japanese: '一', espanol: 'uno'),
    ];
    const dictionary = EspJpnDictionary(
      dictionaryId: 4,
      word: 'uno',
      examples: examples,
    );

    expect(dictionary.copyWith(content: '<b>one</b>').examples, same(examples));
    expect(dictionary.examples!.map((example) => example.exampleId), [2, 1]);
  });

  test('Spanish conjugation uses Catalog mood/tense values', () {
    const tense = TenseConjugacion(
      yo: 'hablo',
      tu: 'hablas',
      el: 'habla',
      nosotros: 'hablamos',
      vosotros: 'hablais',
      ellos: 'hablan',
    );
    const conjugation = EspConjugacions(
      wordId: 9,
      conjugacions: {CatalogMoodTense.indicativePresent: tense},
      participles: EspParticiples(present: 'hablando', past: 'hablado'),
    );

    expect(
      conjugation.conjugacions[CatalogMoodTense.indicativePresent]?.yo,
      'hablo',
    );
  });
}
