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
import 'package:my_dic/features/catalog/internal/domain/word/esp_jpn_word.dart';
import 'package:my_dic/features/catalog/internal/domain/word/jpn_esp_word.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_dataset.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_dictionary_dataset.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';

const _missingConjugation = '--';

/// Converts persistence rows into Catalog internal domain entities.
final class CatalogDriftMapper {
  const CatalogDriftMapper._();

  static EspJpnWord espJpnWord(EspJpnWordTableData row) => EspJpnWord(
        wordId: row.wordId,
        word: row.word,
        partOfSpeech: row.partOfSpeech == null || row.partOfSpeech!.isEmpty
            ? const [CatalogPartOfSpeech.none]
            : row.partOfSpeech!
                .split(',')
                .map(CatalogPartOfSpeech.fromWireValue)
                .toList(),
      );

  static List<EspJpnWord> espJpnWords(List<EspJpnWordTableData> rows) =>
      rows.map(espJpnWord).toList();

  static JpnEspWord jpnEspWord(JpnEspWordTableData row) {
    return JpnEspWord(
      id: row.wordId,
      word: row.word,
    );
  }

  static List<JpnEspWord> jpnEspWords(List<JpnEspWordTableData> rows) =>
      rows.map(jpnEspWord).toList();

  static EspJpnDictionary espJpnDictionary(EspJpnDictionaryDataSet data) =>
      EspJpnDictionary(
        dictionaryId: data.dictionary.dictionaryId,
        word: data.dictionary.word,
        headword: data.dictionary.headword,
        content: data.dictionary.htmlRaw,
        origin: data.dictionary.origin,
        examples: data.examples.isEmpty
            ? null
            : data.examples
                .map((row) => EspJpnExample(
                      exampleId: row.exampleId,
                      japanese: row.japaneseText,
                      espanol: row.espanolText,
                    ))
                .toList(),
        idioms: data.idioms.isEmpty
            ? null
            : data.idioms
                .map((row) => Idiom(
                      idiomId: row.idiomId,
                      idiom: row.idiom,
                      description: row.description,
                    ))
                .toList(),
        supplements: data.supplements.isEmpty
            ? null
            : data.supplements
                .map((row) => Supplement(
                      supplementId: row.supplementId,
                      supplement: row.content,
                    ))
                .toList(),
      );

  static List<EspJpnDictionary> espJpnDictionaries(
    List<EspJpnDictionaryDataSet> data,
  ) =>
      data.map(espJpnDictionary).toList();

  static JpnEspDictionary jpnEspDictionary(JpnEspDictionaryDataSet data) =>
      JpnEspDictionary(
        id: data.dictionary.dictionaryId,
        wordId: data.dictionary.wordId,
        word: data.dictionary.word,
        headword: data.dictionary.headword,
        content: data.dictionary.htmlRaw,
        examples: data.examples.isEmpty
            ? null
            : data.examples
                .map((row) => JpnEspExampleWith(
                      exampleId: row.exampleId,
                      japanese: row.japaneseText,
                      espanol: row.espanolText,
                      espanolHtml: row.espanolHtml,
                    ))
                .toList(),
      );

  static List<JpnEspDictionary> jpnEspDictionaries(
    List<JpnEspDictionaryDataSet> data,
  ) =>
      data.map(jpnEspDictionary).toList();

  static EspJpnConjugation? conjugation(EspConjugationTableData? row) {
    if (row == null) return null;
    return EspJpnConjugation(
      wordId: row.wordId,
      conjugations: {
        CatalogMoodTense.participlePresent: _tense(row.presentParticiple),
        CatalogMoodTense.participlePast: _tense(row.pastParticiple),
        CatalogMoodTense.indicativePresent: _tense(
          row.indicativePresentYo,
          row.indicativePresentTu,
          row.indicativePresentEl,
          row.indicativePresentNosotros,
          row.indicativePresentVosotros,
          row.indicativePresentEllos,
        ),
        CatalogMoodTense.indicativePreterite: _tense(
          row.indicativePreteriteYo,
          row.indicativePreteriteTu,
          row.indicativePreteriteEl,
          row.indicativePreteriteNosotros,
          row.indicativePreteriteVosotros,
          row.indicativePreteriteEllos,
        ),
        CatalogMoodTense.indicativeImperfect: _tense(
          row.indicativeImperfectYo,
          row.indicativeImperfectTu,
          row.indicativeImperfectEl,
          row.indicativeImperfectNosotros,
          row.indicativeImperfectVosotros,
          row.indicativeImperfectEllos,
        ),
        CatalogMoodTense.indicativeFuture: _tense(
          row.indicativeFutureYo,
          row.indicativeFutureTu,
          row.indicativeFutureEl,
          row.indicativeFutureNosotros,
          row.indicativeFutureVosotros,
          row.indicativeFutureEllos,
        ),
        CatalogMoodTense.indicativeConditional: _tense(
          row.indicativeConditionalYo,
          row.indicativeConditionalTu,
          row.indicativeConditionalEl,
          row.indicativeConditionalNosotros,
          row.indicativeConditionalVosotros,
          row.indicativeConditionalEllos,
        ),
        CatalogMoodTense.imperative: _tense(
          null,
          row.imperativeTu,
          row.imperativeEl,
          row.imperativeNosotros,
          row.imperativeVosotros,
          row.imperativeEllos,
        ),
        CatalogMoodTense.subjunctivePresent: _tense(
          row.subjunctivePresentYo,
          row.subjunctivePresentTu,
          row.subjunctivePresentEl,
          row.subjunctivePresentNosotros,
          row.subjunctivePresentVosotros,
          row.subjunctivePresentEllos,
        ),
        CatalogMoodTense.subjunctivePast: _tense(
          row.subjunctivePastYo,
          row.subjunctivePastTu,
          row.subjunctivePastEl,
          row.subjunctivePastNosotros,
          row.subjunctivePastVosotros,
          row.subjunctivePastEllos,
        ),
      },
      participles: EspParticiples(
        present: row.presentParticiple ?? _missingConjugation,
        past: row.pastParticiple ?? _missingConjugation,
      ),
    );
  }

  static TenseConjugation _tense([
    String? yo,
    String? tu,
    String? el,
    String? nosotros,
    String? vosotros,
    String? ellos,
  ]) =>
      TenseConjugation(
        yo: yo ?? _missingConjugation,
        tu: tu ?? _missingConjugation,
        el: el ?? _missingConjugation,
        nosotros: nosotros ?? _missingConjugation,
        vosotros: vosotros ?? _missingConjugation,
        ellos: ellos ?? _missingConjugation,
      );
}
