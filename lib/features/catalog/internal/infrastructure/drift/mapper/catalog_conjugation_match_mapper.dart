import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_search_models.dart';

/// 活用形行に対する、永続化データから型付き一致への唯一のマッピング。
abstract final class CatalogConjugationMatchMapper {
  static Map<CatalogConjugationMatch, String> fromRow(
    EspConjugationTableData row, {
    bool Function(String value)? include,
  }) {
    final result = <CatalogConjugationMatch, String>{};
    void add(CatalogMoodTense tense, CatalogSubject? subject, String? value) {
      if (value == null ||
          value.isEmpty ||
          (include != null && !include(value))) {
        return;
      }
      result[CatalogConjugationMatch(moodTense: tense, subject: subject)] =
          value;
    }

    add(CatalogMoodTense.participlePresent, null, row.presentParticiple);
    add(CatalogMoodTense.participlePast, null, row.pastParticiple);
    final groups = <CatalogMoodTense, List<String?>>{
      CatalogMoodTense.indicativePresent: [
        row.indicativePresentYo,
        row.indicativePresentTu,
        row.indicativePresentEl,
        row.indicativePresentNosotros,
        row.indicativePresentVosotros,
        row.indicativePresentEllos,
      ],
      CatalogMoodTense.indicativePreterite: [
        row.indicativePreteriteYo,
        row.indicativePreteriteTu,
        row.indicativePreteriteEl,
        row.indicativePreteriteNosotros,
        row.indicativePreteriteVosotros,
        row.indicativePreteriteEllos,
      ],
      CatalogMoodTense.indicativeImperfect: [
        row.indicativeImperfectYo,
        row.indicativeImperfectTu,
        row.indicativeImperfectEl,
        row.indicativeImperfectNosotros,
        row.indicativeImperfectVosotros,
        row.indicativeImperfectEllos,
      ],
      CatalogMoodTense.indicativeFuture: [
        row.indicativeFutureYo,
        row.indicativeFutureTu,
        row.indicativeFutureEl,
        row.indicativeFutureNosotros,
        row.indicativeFutureVosotros,
        row.indicativeFutureEllos,
      ],
      CatalogMoodTense.indicativeConditional: [
        row.indicativeConditionalYo,
        row.indicativeConditionalTu,
        row.indicativeConditionalEl,
        row.indicativeConditionalNosotros,
        row.indicativeConditionalVosotros,
        row.indicativeConditionalEllos,
      ],
      CatalogMoodTense.imperative: [
        null,
        row.imperativeTu,
        row.imperativeEl,
        row.imperativeNosotros,
        row.imperativeVosotros,
        row.imperativeEllos,
      ],
      CatalogMoodTense.subjunctivePresent: [
        row.subjunctivePresentYo,
        row.subjunctivePresentTu,
        row.subjunctivePresentEl,
        row.subjunctivePresentNosotros,
        row.subjunctivePresentVosotros,
        row.subjunctivePresentEllos,
      ],
      CatalogMoodTense.subjunctivePast: [
        row.subjunctivePastYo,
        row.subjunctivePastTu,
        row.subjunctivePastEl,
        row.subjunctivePastNosotros,
        row.subjunctivePastVosotros,
        row.subjunctivePastEllos,
      ],
    };
    for (final group in groups.entries) {
      for (var index = 0; index < CatalogSubject.values.length; index++) {
        add(group.key, CatalogSubject.values[index], group.value[index]);
      }
    }
    return result;
  }
}
