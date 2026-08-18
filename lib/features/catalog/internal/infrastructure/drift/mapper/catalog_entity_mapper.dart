import 'package:my_dic/features/catalog/internal/domain/conjugation/esp_conjugations.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/tense_conjugation.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/esp_jpn_dictionary.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/jpn_esp_dictionary.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_entry_detail.dart';
import 'package:my_dic/features/catalog/port/model/esp_jpn_entry.dart';
import 'package:my_dic/features/catalog/port/model/jpn_esp_entry.dart';

/// Converts Catalog internal entities into the immutable public DTO contract.
final class CatalogEntityMapper {
  const CatalogEntityMapper._();

  static EspJpnEntryDetail espJpnDetail(
    CatalogWordRef word,
    List<EspJpnDictionary> dictionaries,
  ) =>
      EspJpnEntryDetail(
        word: word,
        entries: dictionaries
            .map((d) => EspJpnEntry(
                  dictionaryId: d.dictionaryId,
                  word: d.word,
                  headword: d.headword,
                  content: d.content,
                  origin: d.origin,
                  examples: (d.examples ?? const [])
                      .map((e) => EspJpnExample(
                            exampleId: e.exampleId,
                            japanese: e.japanese,
                            espanol: e.espanol,
                          ))
                      .toList(growable: false),
                  idioms: (d.idioms ?? const [])
                      .map((i) => EspJpnIdiom(
                            idiomId: i.idiomId,
                            idiom: i.idiom,
                            description: i.description,
                          ))
                      .toList(growable: false),
                  supplements: (d.supplements ?? const [])
                      .map((s) => CatalogSupplement(
                            supplementId: s.supplementId,
                            supplement: s.supplement,
                          ))
                      .toList(growable: false),
                ))
            .toList(growable: false),
      );

  static JpnEspEntryDetail jpnEspDetail(
    CatalogWordRef word,
    List<JpnEspDictionary> dictionaries,
  ) =>
      JpnEspEntryDetail(
        word: word,
        entries: dictionaries
            .map((d) => JpnEspEntry(
                  dictionaryId: d.id,
                  wordId: d.wordId,
                  word: d.word,
                  headword: d.headword,
                  content: d.content,
                  examples: (d.examples ?? const [])
                      .map((e) => JpnEspExample(
                            exampleId: e.exampleId,
                            japanese: e.japanese,
                            espanol: e.espanol,
                            espanolHtml: e.espanolHtml,
                          ))
                      .toList(growable: false),
                ))
            .toList(growable: false),
      );

  static CatalogConjugation conjugation(
    CatalogWordRef word,
    EspJpnConjugation entity,
  ) =>
      CatalogConjugation(
        word: word,
        conjugations: entity.conjugations.map(
          (key, value) => MapEntry(key, _tense(value)),
        ),
        participles: CatalogParticiples(
          present: entity.participles.present,
          past: entity.participles.past,
        ),
      );

  static CatalogTenseConjugation _tense(TenseConjugation value) =>
      CatalogTenseConjugation(forms: {
        CatalogSubject.yo: value.yo,
        CatalogSubject.tu: value.tu,
        CatalogSubject.el: value.el,
        CatalogSubject.nosotros: value.nosotros,
        CatalogSubject.vosotros: value.vosotros,
        CatalogSubject.ellos: value.ellos,
      });
}
