import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart'
    as legacy;
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart'
    as legacy;
import 'package:my_dic/core/domain/entity/verb/conjugacion/tense_conjugacion.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_entry_detail.dart';
import 'package:my_dic/features/catalog/port/model/esp_jpn_entry.dart';
import 'package:my_dic/features/catalog/port/model/jpn_esp_entry.dart';

/// Pure conversions from legacy domain entities into Catalog-owned DTOs.
final class LegacyCatalogMapper {
  const LegacyCatalogMapper._();

  static EspJpnEntryDetail espJpnDetail(
    CatalogWordRef word,
    List<legacy.EspJpnDictionary> dictionaries,
  ) =>
      EspJpnEntryDetail(
        word: word,
        entries: dictionaries.map(espJpnEntry).toList(growable: false),
      );

  static EspJpnEntry espJpnEntry(legacy.EspJpnDictionary dictionary) =>
      EspJpnEntry(
        dictionaryId: dictionary.dictionaryId,
        word: dictionary.word,
        headword: dictionary.headword,
        content: dictionary.content,
        origin: dictionary.origin,
        examples: (dictionary.examples ?? const [])
            .map(
              (example) => EspJpnExample(
                exampleId: example.exampleId,
                japanese: example.japanese,
                espanol: example.espanol,
              ),
            )
            .toList(growable: false),
        idioms: (dictionary.idioms ?? const [])
            .map(
              (idiom) => EspJpnIdiom(
                idiomId: idiom.idiomId,
                idiom: idiom.idiom,
                description: idiom.description,
              ),
            )
            .toList(growable: false),
        supplements: (dictionary.supplements ?? const [])
            .map(
              (supplement) => CatalogSupplement(
                supplementId: supplement.supplementId,
                supplement: supplement.supplement,
              ),
            )
            .toList(growable: false),
      );

  static JpnEspEntryDetail jpnEspDetail(
    CatalogWordRef word,
    List<legacy.JpnEspDictionary> dictionaries,
  ) =>
      JpnEspEntryDetail(
        word: word,
        entries: dictionaries.map(jpnEspEntry).toList(growable: false),
      );

  static JpnEspEntry jpnEspEntry(legacy.JpnEspDictionary dictionary) =>
      JpnEspEntry(
        dictionaryId: dictionary.id,
        wordId: dictionary.wordId,
        word: dictionary.word,
        headword: dictionary.headword,
        content: dictionary.content,
        examples: (dictionary.examples ?? const [])
            .map(
              (example) => JpnEspExample(
                exampleId: example.exampleId,
                japanese: example.japanese,
                espanol: example.espanol,
                espanolHtml: example.espanolHtml,
              ),
            )
            .toList(growable: false),
      );

  static CatalogConjugation conjugation(
    CatalogWordRef word,
    EspConjugacions legacyConjugation,
  ) =>
      CatalogConjugation(
        word: word,
        conjugations: legacyConjugation.conjugacions.map(
          (moodTense, tense) => MapEntry(
            CatalogMoodTense.values.byName(moodTense.name),
            _tense(tense),
          ),
        ),
        participles: CatalogParticiples(
          present: legacyConjugation.participles.present,
          past: legacyConjugation.participles.past,
        ),
      );

  static CatalogTenseConjugation _tense(TenseConjugacion tense) =>
      CatalogTenseConjugation(
        forms: {
          CatalogSubject.yo: tense.yo,
          CatalogSubject.tu: tense.tu,
          CatalogSubject.el: tense.el,
          CatalogSubject.nosotros: tense.nosotros,
          CatalogSubject.vosotros: tense.vosotros,
          CatalogSubject.ellos: tense.ellos,
        },
      );
}
