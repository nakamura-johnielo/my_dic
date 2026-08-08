import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart'
    as legacy;
import 'package:my_dic/core/domain/entity/dictionary/sub/example/impl/esp_jpn_example.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/tense_conjugacion.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/core/domain/entity/verb/participles.dart';
import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/legacy_catalog_mapper.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 71);

  test('mapper detaches nested legacy collections into immutable Catalog DTOs',
      () {
    final examples = [
      const EspJpnExample(
        exampleId: 1,
        japanese: 'Japanese example',
        espanol: 'hablar',
      ),
    ];
    final entry = LegacyCatalogMapper.espJpnEntry(
      legacy.EspJpnDictionary(
        dictionaryId: 12,
        word: 'hablar',
        examples: examples,
      ),
    );

    examples.clear();
    expect(entry.examples.single.japanese, 'Japanese example');
    expect(() => entry.examples.clear(), throwsUnsupportedError);

    const tense = TenseConjugacion(
      yo: 'hablo',
      tu: 'hablas',
      el: 'habla',
      nosotros: 'hablamos',
      vosotros: 'hablais',
      ellos: 'hablan',
    );
    final legacyConjugations = <MoodTense, TenseConjugacion>{
      MoodTense.indicativePresent: tense,
    };
    final conjugation = LegacyCatalogMapper.conjugation(
      word,
      EspConjugacions(
        wordId: word.wordId,
        conjugacions: legacyConjugations,
        participles: const EspParticiples(present: 'hablando', past: 'hablado'),
      ),
    );

    legacyConjugations.clear();
    final forms = conjugation.conjugations[CatalogMoodTense.indicativePresent]!;
    expect(forms[CatalogSubject.yo], 'hablo');
    expect(() => conjugation.conjugations.clear(), throwsUnsupportedError);
    expect(() => forms.forms.clear(), throwsUnsupportedError);
  });
}
