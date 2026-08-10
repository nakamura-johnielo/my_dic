import 'package:drift/drift.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/conjugations.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

part '../../../../../../../__generated/features/catalog/internal/infrastructure/drift/dao/esp_jpn/conjugation_dao.g.dart';

@DriftAccessor(tables: [EspConjugations])
class ConjugationDao extends DatabaseAccessor<DatabaseProvider>
    with _$ConjugationDaoMixin {
  ConjugationDao(super.database);

  Future<String?> getMeaningById(int id) async {
    final query = select(espConjugations)
      ..where((tbl) => tbl.wordId.equals(id))
      ..addColumns([espConjugations.meaning]);
    final result = await query.getSingleOrNull();
    return result?.meaning;
  }

  Future<Map<int, String>> getMeaningsByWordIds(List<int> wordIds) async {
    if (wordIds.isEmpty) return {};

    final query = select(espConjugations)
      ..where((tbl) => tbl.wordId.isIn(wordIds))
      ..addColumns([espConjugations.wordId, espConjugations.meaning]);

    final rows = await query.get();
    final res = <int, String>{};
    for (final row in rows) {
      final meaning = row.meaning;
      if (meaning == null || meaning.isEmpty) continue;
      res[row.wordId] = meaning;
    }
    return res;
  }

  Future<bool> exists(int wordId) async {
    final query = select(espConjugations)
      ..where((tbl) => tbl.wordId.equals(wordId))
      ..addColumns([espConjugations.wordId]);
    final result = await query.getSingleOrNull();

    final res = result?.wordId != null ? true : false;
    return res;
  }

  Future<EspConjugationTableData?> getConjugationById(int id) {
    return (select(espConjugations)..where((tbl) => tbl.wordId.equals(id)))
        .getSingleOrNull();
  }

  Future<List<EspConjugationTableData>> getConjugationByWordWithPage(
    String word,
    int size,
    int requiredPage,
  ) async {
    final mainQuery = customSelect(
      '''
      ${getAllQuery(word)}  
      limit $size offset ${size * requiredPage}
      ''',
      readsFrom: {espConjugations},
    );
    final res = await mainQuery.get();

    return res.map((row) {
      return EspConjugationTableData(
        wordId: row.read<int>('word_id'),
        word: row.read<String>('word'),
        meaning: row.read<String?>('meaning'),
        presentParticiple: row.read<String?>('present_participle'),
        pastParticiple: row.read<String?>('past_participle'),
        indicativePresentYo: row.read<String?>('indicative_present_yo'),
        indicativePresentTu: row.read<String?>('indicative_present_tu'),
        indicativePresentEl: row.read<String?>('indicative_present_el'),
        indicativePresentNosotros:
            row.read<String?>('indicative_present_nosotros'),
        indicativePresentVosotros:
            row.read<String?>('indicative_present_vosotros'),
        indicativePresentEllos: row.read<String?>('indicative_present_ellos'),
        indicativePreteriteYo: row.read<String?>('indicative_preterite_yo'),
        indicativePreteriteTu: row.read<String?>('indicative_preterite_tu'),
        indicativePreteriteEl: row.read<String?>('indicative_preterite_el'),
        indicativePreteriteNosotros:
            row.read<String?>('indicative_preterite_nosotros'),
        indicativePreteriteVosotros:
            row.read<String?>('indicative_preterite_vosotros'),
        indicativePreteriteEllos:
            row.read<String?>('indicative_preterite_ellos'),
        indicativeImperfectYo: row.read<String?>('indicative_imperfect_yo'),
        indicativeImperfectTu: row.read<String?>('indicative_imperfect_tu'),
        indicativeImperfectEl: row.read<String?>('indicative_imperfect_el'),
        indicativeImperfectNosotros:
            row.read<String?>('indicative_imperfect_nosotros'),
        indicativeImperfectVosotros:
            row.read<String?>('indicative_imperfect_vosotros'),
        indicativeImperfectEllos:
            row.read<String?>('indicative_imperfect_ellos'),
        indicativeFutureYo: row.read<String?>('indicative_future_yo'),
        indicativeFutureTu: row.read<String?>('indicative_future_tu'),
        indicativeFutureEl: row.read<String?>('indicative_future_el'),
        indicativeFutureNosotros:
            row.read<String?>('indicative_future_nosotros'),
        indicativeFutureVosotros:
            row.read<String?>('indicative_future_vosotros'),
        indicativeFutureEllos: row.read<String?>('indicative_future_ellos'),
        indicativeConditionalYo: row.read<String?>('indicative_conditional_yo'),
        indicativeConditionalTu: row.read<String?>('indicative_conditional_tu'),
        indicativeConditionalEl: row.read<String?>('indicative_conditional_el'),
        indicativeConditionalNosotros:
            row.read<String?>('indicative_conditional_nosotros'),
        indicativeConditionalVosotros:
            row.read<String?>('indicative_conditional_vosotros'),
        indicativeConditionalEllos:
            row.read<String?>('indicative_conditional_ellos'),
        imperativeTu: row.read<String?>('imperative_tu'),
        imperativeEl: row.read<String?>('imperative_el'),
        imperativeNosotros: row.read<String?>('imperative_nosotros'),
        imperativeVosotros: row.read<String?>('imperative_vosotros'),
        imperativeEllos: row.read<String?>('imperative_ellos'),
        subjunctivePresentYo: row.read<String?>('subjunctive_present_yo'),
        subjunctivePresentTu: row.read<String?>('subjunctive_present_tu'),
        subjunctivePresentEl: row.read<String?>('subjunctive_present_el'),
        subjunctivePresentNosotros:
            row.read<String?>('subjunctive_present_nosotros'),
        subjunctivePresentVosotros:
            row.read<String?>('subjunctive_present_vosotros'),
        subjunctivePresentEllos: row.read<String?>('subjunctive_present_ellos'),
        subjunctivePastYo: row.read<String?>('subjunctive_past_yo'),
        subjunctivePastTu: row.read<String?>('subjunctive_past_tu'),
        subjunctivePastEl: row.read<String?>('subjunctive_past_el'),
        subjunctivePastNosotros: row.read<String?>('subjunctive_past_nosotros'),
        subjunctivePastVosotros: row.read<String?>('subjunctive_past_vosotros'),
        subjunctivePastEllos: row.read<String?>('subjunctive_past_ellos'),
      );
    }).toList();
  }

  Future<List<EspConjugationTableData>> getConjugationInAllTableByWordWithPage(
    String word,
    int size,
    int requiredPage,
  ) async {
    final mainQuery = customSelect(
      '''
      ${getAllQueryWithWordColumn(word)}  
      limit $size offset ${size * requiredPage}
      ''',
      readsFrom: {espConjugations},
    );

    AppLogger.print("````````````````````````````````` in dao");

    try {
      final resTest = await mainQuery.get();
      AppLogger.print("${resTest.length} in dao test");
    } catch (e) {
      AppLogger.print("Error in dao test: $e");
    }
    final res = await mainQuery.get();
    AppLogger.print("${res.length} in dao");

    return res.map((row) {
      return EspConjugationTableData(
        wordId: row.read<int>('word_id'),
        word: row.read<String>('word'),
        meaning: row.read<String?>('meaning'),
        presentParticiple: row.read<String?>('present_participle'),
        pastParticiple: row.read<String?>('past_participle'),
        indicativePresentYo: row.read<String?>('indicative_present_yo'),
        indicativePresentTu: row.read<String?>('indicative_present_tu'),
        indicativePresentEl: row.read<String?>('indicative_present_el'),
        indicativePresentNosotros:
            row.read<String?>('indicative_present_nosotros'),
        indicativePresentVosotros:
            row.read<String?>('indicative_present_vosotros'),
        indicativePresentEllos: row.read<String?>('indicative_present_ellos'),
        indicativePreteriteYo: row.read<String?>('indicative_preterite_yo'),
        indicativePreteriteTu: row.read<String?>('indicative_preterite_tu'),
        indicativePreteriteEl: row.read<String?>('indicative_preterite_el'),
        indicativePreteriteNosotros:
            row.read<String?>('indicative_preterite_nosotros'),
        indicativePreteriteVosotros:
            row.read<String?>('indicative_preterite_vosotros'),
        indicativePreteriteEllos:
            row.read<String?>('indicative_preterite_ellos'),
        indicativeImperfectYo: row.read<String?>('indicative_imperfect_yo'),
        indicativeImperfectTu: row.read<String?>('indicative_imperfect_tu'),
        indicativeImperfectEl: row.read<String?>('indicative_imperfect_el'),
        indicativeImperfectNosotros:
            row.read<String?>('indicative_imperfect_nosotros'),
        indicativeImperfectVosotros:
            row.read<String?>('indicative_imperfect_vosotros'),
        indicativeImperfectEllos:
            row.read<String?>('indicative_imperfect_ellos'),
        indicativeFutureYo: row.read<String?>('indicative_future_yo'),
        indicativeFutureTu: row.read<String?>('indicative_future_tu'),
        indicativeFutureEl: row.read<String?>('indicative_future_el'),
        indicativeFutureNosotros:
            row.read<String?>('indicative_future_nosotros'),
        indicativeFutureVosotros:
            row.read<String?>('indicative_future_vosotros'),
        indicativeFutureEllos: row.read<String?>('indicative_future_ellos'),
        indicativeConditionalYo: row.read<String?>('indicative_conditional_yo'),
        indicativeConditionalTu: row.read<String?>('indicative_conditional_tu'),
        indicativeConditionalEl: row.read<String?>('indicative_conditional_el'),
        indicativeConditionalNosotros:
            row.read<String?>('indicative_conditional_nosotros'),
        indicativeConditionalVosotros:
            row.read<String?>('indicative_conditional_vosotros'),
        indicativeConditionalEllos:
            row.read<String?>('indicative_conditional_ellos'),
        imperativeTu: row.read<String?>('imperative_tu'),
        imperativeEl: row.read<String?>('imperative_el'),
        imperativeNosotros: row.read<String?>('imperative_nosotros'),
        imperativeVosotros: row.read<String?>('imperative_vosotros'),
        imperativeEllos: row.read<String?>('imperative_ellos'),
        subjunctivePresentYo: row.read<String?>('subjunctive_present_yo'),
        subjunctivePresentTu: row.read<String?>('subjunctive_present_tu'),
        subjunctivePresentEl: row.read<String?>('subjunctive_present_el'),
        subjunctivePresentNosotros:
            row.read<String?>('subjunctive_present_nosotros'),
        subjunctivePresentVosotros:
            row.read<String?>('subjunctive_present_vosotros'),
        subjunctivePresentEllos: row.read<String?>('subjunctive_present_ellos'),
        subjunctivePastYo: row.read<String?>('subjunctive_past_yo'),
        subjunctivePastTu: row.read<String?>('subjunctive_past_tu'),
        subjunctivePastEl: row.read<String?>('subjunctive_past_el'),
        subjunctivePastNosotros: row.read<String?>('subjunctive_past_nosotros'),
        subjunctivePastVosotros: row.read<String?>('subjunctive_past_vosotros'),
        subjunctivePastEllos: row.read<String?>('subjunctive_past_ellos'),
      );
    }).toList();
  }

}

String getAllQuery(String query) {
  //wordid,word,一致するカラムの値、不一致ははNULL
  //完全一致が先頭
  String res = "";
  res = '''
SELECT word_id, word,
      CASE WHEN present_participle LIKE '$query%' THEN present_participle ELSE '' END AS 'present_participle',
      CASE WHEN past_participle LIKE '$query%' THEN past_participle ELSE '' END AS 'past_participle',
      CASE WHEN indicative_present_yo LIKE '$query%' THEN indicative_present_yo ELSE '' END AS 'indicative_present_yo',
      CASE WHEN indicative_present_tu LIKE '$query%' THEN indicative_present_tu ELSE '' END AS 'indicative_present_tu',
      CASE WHEN indicative_present_el LIKE '$query%' THEN indicative_present_el ELSE '' END AS 'indicative_present_el',
      CASE WHEN indicative_present_nosotros LIKE '$query%' THEN indicative_present_nosotros ELSE '' END AS 'indicative_present_nosotros',
      CASE WHEN indicative_present_vosotros LIKE '$query%' THEN indicative_present_vosotros ELSE '' END AS 'indicative_present_vosotros',
      CASE WHEN indicative_present_ellos LIKE '$query%' THEN indicative_present_ellos ELSE '' END AS 'indicative_present_ellos',
      CASE WHEN indicative_preterite_yo LIKE '$query%' THEN indicative_preterite_yo ELSE '' END AS 'indicative_preterite_yo',
      CASE WHEN indicative_preterite_tu LIKE '$query%' THEN indicative_preterite_tu ELSE '' END AS 'indicative_preterite_tu',
      CASE WHEN indicative_preterite_el LIKE '$query%' THEN indicative_preterite_el ELSE '' END AS 'indicative_preterite_el',
      CASE WHEN indicative_preterite_nosotros LIKE '$query%' THEN indicative_preterite_nosotros ELSE '' END AS 'indicative_preterite_nosotros',
      CASE WHEN indicative_preterite_vosotros LIKE '$query%' THEN indicative_preterite_vosotros ELSE '' END AS 'indicative_preterite_vosotros',
      CASE WHEN indicative_preterite_ellos LIKE '$query%' THEN indicative_preterite_ellos ELSE '' END AS 'indicative_preterite_ellos',
      CASE WHEN indicative_imperfect_yo LIKE '$query%' THEN indicative_imperfect_yo ELSE '' END AS 'indicative_imperfect_yo',
      CASE WHEN indicative_imperfect_tu LIKE '$query%' THEN indicative_imperfect_tu ELSE '' END AS 'indicative_imperfect_tu',
      CASE WHEN indicative_imperfect_el LIKE '$query%' THEN indicative_imperfect_el ELSE '' END AS 'indicative_imperfect_el',
      CASE WHEN indicative_imperfect_nosotros LIKE '$query%' THEN indicative_imperfect_nosotros ELSE '' END AS 'indicative_imperfect_nosotros',
      CASE WHEN indicative_imperfect_vosotros LIKE '$query%' THEN indicative_imperfect_vosotros ELSE '' END AS 'indicative_imperfect_vosotros',
      CASE WHEN indicative_imperfect_ellos LIKE '$query%' THEN indicative_imperfect_ellos ELSE '' END AS 'indicative_imperfect_ellos',
      CASE WHEN indicative_future_yo LIKE '$query%' THEN indicative_future_yo ELSE '' END AS 'indicative_future_yo',
      CASE WHEN indicative_future_tu LIKE '$query%' THEN indicative_future_tu ELSE '' END AS 'indicative_future_tu',
      CASE WHEN indicative_future_el LIKE '$query%' THEN indicative_future_el ELSE '' END AS 'indicative_future_el',
      CASE WHEN indicative_future_nosotros LIKE '$query%' THEN indicative_future_nosotros ELSE '' END AS 'indicative_future_nosotros',
      CASE WHEN indicative_future_vosotros LIKE '$query%' THEN indicative_future_vosotros ELSE '' END AS 'indicative_future_vosotros',
      CASE WHEN indicative_future_ellos LIKE '$query%' THEN indicative_future_ellos ELSE '' END AS 'indicative_future_ellos',
      CASE WHEN indicative_conditional_yo LIKE '$query%' THEN indicative_conditional_yo ELSE '' END AS 'indicative_conditional_yo',
      CASE WHEN indicative_conditional_tu LIKE '$query%' THEN indicative_conditional_tu ELSE '' END AS 'indicative_conditional_tu',
      CASE WHEN indicative_conditional_el LIKE '$query%' THEN indicative_conditional_el ELSE '' END AS 'indicative_conditional_el',
      CASE WHEN indicative_conditional_nosotros LIKE '$query%' THEN indicative_conditional_nosotros ELSE '' END AS 'indicative_conditional_nosotros',
      CASE WHEN indicative_conditional_vosotros LIKE '$query%' THEN indicative_conditional_vosotros ELSE '' END AS 'indicative_conditional_vosotros',
      CASE WHEN indicative_conditional_ellos LIKE '$query%' THEN indicative_conditional_ellos ELSE '' END AS 'indicative_conditional_ellos',
      CASE WHEN imperative_tu LIKE '$query%' THEN imperative_tu ELSE '' END AS 'imperative_tu',
      CASE WHEN imperative_el LIKE '$query%' THEN imperative_el ELSE '' END AS 'imperative_el',
      CASE WHEN imperative_nosotros LIKE '$query%' THEN imperative_nosotros ELSE '' END AS 'imperative_nosotros',
      CASE WHEN imperative_vosotros LIKE '$query%' THEN imperative_vosotros ELSE '' END AS 'imperative_vosotros',
      CASE WHEN imperative_ellos LIKE '$query%' THEN imperative_ellos ELSE '' END AS 'imperative_ellos',
      CASE WHEN subjunctive_present_yo LIKE '$query%' THEN subjunctive_present_yo ELSE '' END AS 'subjunctive_present_yo',
      CASE WHEN subjunctive_present_tu LIKE '$query%' THEN subjunctive_present_tu ELSE '' END AS 'subjunctive_present_tu',
      CASE WHEN subjunctive_present_el LIKE '$query%' THEN subjunctive_present_el ELSE '' END AS 'subjunctive_present_el',
      CASE WHEN subjunctive_present_nosotros LIKE '$query%' THEN subjunctive_present_nosotros ELSE '' END AS 'subjunctive_present_nosotros',
      CASE WHEN subjunctive_present_vosotros LIKE '$query%' THEN subjunctive_present_vosotros ELSE '' END AS 'subjunctive_present_vosotros',
      CASE WHEN subjunctive_present_ellos LIKE '$query%' THEN subjunctive_present_ellos ELSE '' END AS 'subjunctive_present_ellos',
      CASE WHEN subjunctive_past_yo LIKE '$query%' THEN subjunctive_past_yo ELSE '' END AS 'subjunctive_past_yo',
      CASE WHEN subjunctive_past_tu LIKE '$query%' THEN subjunctive_past_tu ELSE '' END AS 'subjunctive_past_tu',
      CASE WHEN subjunctive_past_el LIKE '$query%' THEN subjunctive_past_el ELSE '' END AS 'subjunctive_past_el',
      CASE WHEN subjunctive_past_nosotros LIKE '$query%' THEN subjunctive_past_nosotros ELSE '' END AS 'subjunctive_past_nosotros',
      CASE WHEN subjunctive_past_vosotros LIKE '$query%' THEN subjunctive_past_vosotros ELSE '' END AS 'subjunctive_past_vosotros',
      CASE WHEN subjunctive_past_ellos LIKE '$query%' THEN subjunctive_past_ellos ELSE '' END AS 'subjunctive_past_ellos'
FROM conjugations 
WHERE present_participle LIKE '$query%'  OR
      past_participle LIKE '$query%'  OR
      indicative_present_yo LIKE '$query%'  OR
      indicative_present_tu LIKE '$query%'  OR
      indicative_present_el LIKE '$query%'  OR
      indicative_present_nosotros LIKE '$query%'  OR
      indicative_present_vosotros LIKE '$query%'  OR
      indicative_present_ellos LIKE '$query%'  OR
      indicative_preterite_yo LIKE '$query%'  OR
      indicative_preterite_tu LIKE '$query%'  OR 
      indicative_preterite_el LIKE '$query%'  OR
      indicative_preterite_nosotros LIKE '$query%'  OR
      indicative_preterite_vosotros LIKE '$query%'  OR
      indicative_preterite_ellos LIKE '$query%'  OR
      indicative_imperfect_yo LIKE '$query%'  OR
      indicative_imperfect_tu LIKE '$query%'  OR
      indicative_imperfect_el LIKE '$query%'  OR
      indicative_imperfect_nosotros LIKE '$query%'  OR
      indicative_imperfect_vosotros LIKE '$query%'  OR
      indicative_imperfect_ellos LIKE '$query%'  OR
      indicative_future_yo LIKE '$query%'  OR
      indicative_future_tu LIKE '$query%'  OR
      indicative_future_el LIKE '$query%'  OR
      indicative_future_nosotros LIKE '$query%'  OR
      indicative_future_vosotros LIKE '$query%'  OR
      indicative_future_ellos LIKE '$query%'  OR
      indicative_conditional_yo LIKE '$query%'  OR
      indicative_conditional_tu LIKE '$query%'  OR
      indicative_conditional_el LIKE '$query%'  OR
      indicative_conditional_nosotros LIKE '$query%'  OR
      indicative_conditional_vosotros LIKE '$query%'  OR
      indicative_conditional_ellos LIKE '$query%'  OR
      imperative_tu LIKE '$query%'  OR
      imperative_el LIKE '$query%'    OR
      imperative_nosotros LIKE '$query%'  OR
      imperative_vosotros LIKE '$query%'  OR
      imperative_ellos LIKE '$query%'  OR
      subjunctive_present_yo LIKE '$query%'  OR
      subjunctive_present_tu LIKE '$query%'  OR
      subjunctive_present_el LIKE '$query%'  OR
      subjunctive_present_nosotros LIKE '$query%'  OR
      subjunctive_present_vosotros LIKE '$query%'  OR
      subjunctive_present_ellos LIKE '$query%'  OR
      subjunctive_past_yo LIKE '$query%'  OR
      subjunctive_past_tu LIKE '$query%'  OR
      subjunctive_past_el LIKE '$query%'  OR
      subjunctive_past_nosotros LIKE '$query%'  OR
      subjunctive_past_vosotros LIKE '$query%'  OR
      subjunctive_past_ellos LIKE '$query%'
ORDER BY
      (CASE 
          WHEN present_participle = '$query'  OR
              past_participle = '$query'  OR
              indicative_present_yo = '$query'  OR
              indicative_present_tu = '$query'  OR
              indicative_present_el = '$query'  OR
              indicative_present_nosotros = '$query'  OR
              indicative_present_vosotros = '$query'  OR
              indicative_present_ellos = '$query'  OR
              indicative_preterite_yo = '$query'  OR
              indicative_preterite_tu = '$query'  OR 
              indicative_preterite_el = '$query'  OR
              indicative_preterite_nosotros = '$query'  OR
              indicative_preterite_vosotros = '$query'  OR
              indicative_preterite_ellos = '$query'  OR
              indicative_imperfect_yo = '$query'  OR
              indicative_imperfect_tu = '$query'  OR
              indicative_imperfect_el = '$query'  OR
              indicative_imperfect_nosotros = '$query'  OR
              indicative_imperfect_vosotros = '$query'  OR
              indicative_imperfect_ellos = '$query'  OR
              indicative_future_yo = '$query'  OR
              indicative_future_tu = '$query'  OR
              indicative_future_el = '$query'  OR
              indicative_future_nosotros = '$query'  OR
              indicative_future_vosotros = '$query'  OR
              indicative_future_ellos = '$query'  OR
              indicative_conditional_yo = '$query'  OR
              indicative_conditional_tu = '$query'  OR
              indicative_conditional_el = '$query'  OR
              indicative_conditional_nosotros = '$query'  OR
              indicative_conditional_vosotros = '$query'  OR
              indicative_conditional_ellos = '$query'  OR
              imperative_tu = '$query'  OR
              imperative_el = '$query'    OR
              imperative_nosotros = '$query'  OR
              imperative_vosotros = '$query'  OR
              imperative_ellos = '$query'  OR
              subjunctive_present_yo = '$query'  OR
              subjunctive_present_tu = '$query'  OR
              subjunctive_present_el = '$query'  OR
              subjunctive_present_nosotros = '$query'  OR
              subjunctive_present_vosotros = '$query'  OR
              subjunctive_present_ellos = '$query'  OR
              subjunctive_past_yo = '$query'  OR
              subjunctive_past_tu = '$query'  OR
              subjunctive_past_el = '$query'  OR
              subjunctive_past_nosotros = '$query'  OR
              subjunctive_past_vosotros = '$query'  OR
              subjunctive_past_ellos = '$query'
          THEN 0 
          ELSE 1 
      END)
      , word_id
        ''';
  return res;
}

String getAllQueryWithWordColumn(String query) {
  //wordid,word,一致するカラムの値、不一致ははNULL
  //完全一致が先頭
  String res = "";
  res = '''
SELECT word_id, word,meaning,
      CASE WHEN present_participle LIKE '$query%' THEN present_participle ELSE '' END AS 'present_participle',
      CASE WHEN past_participle LIKE '$query%' THEN past_participle ELSE '' END AS 'past_participle',
      CASE WHEN indicative_present_yo LIKE '$query%' THEN indicative_present_yo ELSE '' END AS 'indicative_present_yo',
      CASE WHEN indicative_present_tu LIKE '$query%' THEN indicative_present_tu ELSE '' END AS 'indicative_present_tu',
      CASE WHEN indicative_present_el LIKE '$query%' THEN indicative_present_el ELSE '' END AS 'indicative_present_el',
      CASE WHEN indicative_present_nosotros LIKE '$query%' THEN indicative_present_nosotros ELSE '' END AS 'indicative_present_nosotros',
      CASE WHEN indicative_present_vosotros LIKE '$query%' THEN indicative_present_vosotros ELSE '' END AS 'indicative_present_vosotros',
      CASE WHEN indicative_present_ellos LIKE '$query%' THEN indicative_present_ellos ELSE '' END AS 'indicative_present_ellos',
      CASE WHEN indicative_preterite_yo LIKE '$query%' THEN indicative_preterite_yo ELSE '' END AS 'indicative_preterite_yo',
      CASE WHEN indicative_preterite_tu LIKE '$query%' THEN indicative_preterite_tu ELSE '' END AS 'indicative_preterite_tu',
      CASE WHEN indicative_preterite_el LIKE '$query%' THEN indicative_preterite_el ELSE '' END AS 'indicative_preterite_el',
      CASE WHEN indicative_preterite_nosotros LIKE '$query%' THEN indicative_preterite_nosotros ELSE '' END AS 'indicative_preterite_nosotros',
      CASE WHEN indicative_preterite_vosotros LIKE '$query%' THEN indicative_preterite_vosotros ELSE '' END AS 'indicative_preterite_vosotros',
      CASE WHEN indicative_preterite_ellos LIKE '$query%' THEN indicative_preterite_ellos ELSE '' END AS 'indicative_preterite_ellos',
      CASE WHEN indicative_imperfect_yo LIKE '$query%' THEN indicative_imperfect_yo ELSE '' END AS 'indicative_imperfect_yo',
      CASE WHEN indicative_imperfect_tu LIKE '$query%' THEN indicative_imperfect_tu ELSE '' END AS 'indicative_imperfect_tu',
      CASE WHEN indicative_imperfect_el LIKE '$query%' THEN indicative_imperfect_el ELSE '' END AS 'indicative_imperfect_el',
      CASE WHEN indicative_imperfect_nosotros LIKE '$query%' THEN indicative_imperfect_nosotros ELSE '' END AS 'indicative_imperfect_nosotros',
      CASE WHEN indicative_imperfect_vosotros LIKE '$query%' THEN indicative_imperfect_vosotros ELSE '' END AS 'indicative_imperfect_vosotros',
      CASE WHEN indicative_imperfect_ellos LIKE '$query%' THEN indicative_imperfect_ellos ELSE '' END AS 'indicative_imperfect_ellos',
      CASE WHEN indicative_future_yo LIKE '$query%' THEN indicative_future_yo ELSE '' END AS 'indicative_future_yo',
      CASE WHEN indicative_future_tu LIKE '$query%' THEN indicative_future_tu ELSE '' END AS 'indicative_future_tu',
      CASE WHEN indicative_future_el LIKE '$query%' THEN indicative_future_el ELSE '' END AS 'indicative_future_el',
      CASE WHEN indicative_future_nosotros LIKE '$query%' THEN indicative_future_nosotros ELSE '' END AS 'indicative_future_nosotros',
      CASE WHEN indicative_future_vosotros LIKE '$query%' THEN indicative_future_vosotros ELSE '' END AS 'indicative_future_vosotros',
      CASE WHEN indicative_future_ellos LIKE '$query%' THEN indicative_future_ellos ELSE '' END AS 'indicative_future_ellos',
      CASE WHEN indicative_conditional_yo LIKE '$query%' THEN indicative_conditional_yo ELSE '' END AS 'indicative_conditional_yo',
      CASE WHEN indicative_conditional_tu LIKE '$query%' THEN indicative_conditional_tu ELSE '' END AS 'indicative_conditional_tu',
      CASE WHEN indicative_conditional_el LIKE '$query%' THEN indicative_conditional_el ELSE '' END AS 'indicative_conditional_el',
      CASE WHEN indicative_conditional_nosotros LIKE '$query%' THEN indicative_conditional_nosotros ELSE '' END AS 'indicative_conditional_nosotros',
      CASE WHEN indicative_conditional_vosotros LIKE '$query%' THEN indicative_conditional_vosotros ELSE '' END AS 'indicative_conditional_vosotros',
      CASE WHEN indicative_conditional_ellos LIKE '$query%' THEN indicative_conditional_ellos ELSE '' END AS 'indicative_conditional_ellos',
      CASE WHEN imperative_tu LIKE '$query%' THEN imperative_tu ELSE '' END AS 'imperative_tu',
      CASE WHEN imperative_el LIKE '$query%' THEN imperative_el ELSE '' END AS 'imperative_el',
      CASE WHEN imperative_nosotros LIKE '$query%' THEN imperative_nosotros ELSE '' END AS 'imperative_nosotros',
      CASE WHEN imperative_vosotros LIKE '$query%' THEN imperative_vosotros ELSE '' END AS 'imperative_vosotros',
      CASE WHEN imperative_ellos LIKE '$query%' THEN imperative_ellos ELSE '' END AS 'imperative_ellos',
      CASE WHEN subjunctive_present_yo LIKE '$query%' THEN subjunctive_present_yo ELSE '' END AS 'subjunctive_present_yo',
      CASE WHEN subjunctive_present_tu LIKE '$query%' THEN subjunctive_present_tu ELSE '' END AS 'subjunctive_present_tu',
      CASE WHEN subjunctive_present_el LIKE '$query%' THEN subjunctive_present_el ELSE '' END AS 'subjunctive_present_el',
      CASE WHEN subjunctive_present_nosotros LIKE '$query%' THEN subjunctive_present_nosotros ELSE '' END AS 'subjunctive_present_nosotros',
      CASE WHEN subjunctive_present_vosotros LIKE '$query%' THEN subjunctive_present_vosotros ELSE '' END AS 'subjunctive_present_vosotros',
      CASE WHEN subjunctive_present_ellos LIKE '$query%' THEN subjunctive_present_ellos ELSE '' END AS 'subjunctive_present_ellos',
      CASE WHEN subjunctive_past_yo LIKE '$query%' THEN subjunctive_past_yo ELSE '' END AS 'subjunctive_past_yo',
      CASE WHEN subjunctive_past_tu LIKE '$query%' THEN subjunctive_past_tu ELSE '' END AS 'subjunctive_past_tu',
      CASE WHEN subjunctive_past_el LIKE '$query%' THEN subjunctive_past_el ELSE '' END AS 'subjunctive_past_el',
      CASE WHEN subjunctive_past_nosotros LIKE '$query%' THEN subjunctive_past_nosotros ELSE '' END AS 'subjunctive_past_nosotros',
      CASE WHEN subjunctive_past_vosotros LIKE '$query%' THEN subjunctive_past_vosotros ELSE '' END AS 'subjunctive_past_vosotros',
      CASE WHEN subjunctive_past_ellos LIKE '$query%' THEN subjunctive_past_ellos ELSE '' END AS 'subjunctive_past_ellos'
FROM conjugations 
WHERE 
      word LIKE '$query%' OR
      present_participle LIKE '$query%'  OR
      past_participle LIKE '$query%'  OR
      indicative_present_yo LIKE '$query%'  OR
      indicative_present_tu LIKE '$query%'  OR
      indicative_present_el LIKE '$query%'  OR
      indicative_present_nosotros LIKE '$query%'  OR
      indicative_present_vosotros LIKE '$query%'  OR
      indicative_present_ellos LIKE '$query%'  OR
      indicative_preterite_yo LIKE '$query%'  OR
      indicative_preterite_tu LIKE '$query%'  OR 
      indicative_preterite_el LIKE '$query%'  OR
      indicative_preterite_nosotros LIKE '$query%'  OR
      indicative_preterite_vosotros LIKE '$query%'  OR
      indicative_preterite_ellos LIKE '$query%'  OR
      indicative_imperfect_yo LIKE '$query%'  OR
      indicative_imperfect_tu LIKE '$query%'  OR
      indicative_imperfect_el LIKE '$query%'  OR
      indicative_imperfect_nosotros LIKE '$query%'  OR
      indicative_imperfect_vosotros LIKE '$query%'  OR
      indicative_imperfect_ellos LIKE '$query%'  OR
      indicative_future_yo LIKE '$query%'  OR
      indicative_future_tu LIKE '$query%'  OR
      indicative_future_el LIKE '$query%'  OR
      indicative_future_nosotros LIKE '$query%'  OR
      indicative_future_vosotros LIKE '$query%'  OR
      indicative_future_ellos LIKE '$query%'  OR
      indicative_conditional_yo LIKE '$query%'  OR
      indicative_conditional_tu LIKE '$query%'  OR
      indicative_conditional_el LIKE '$query%'  OR
      indicative_conditional_nosotros LIKE '$query%'  OR
      indicative_conditional_vosotros LIKE '$query%'  OR
      indicative_conditional_ellos LIKE '$query%'  OR
      imperative_tu LIKE '$query%'  OR
      imperative_el LIKE '$query%'    OR
      imperative_nosotros LIKE '$query%'  OR
      imperative_vosotros LIKE '$query%'  OR
      imperative_ellos LIKE '$query%'  OR
      subjunctive_present_yo LIKE '$query%'  OR
      subjunctive_present_tu LIKE '$query%'  OR
      subjunctive_present_el LIKE '$query%'  OR
      subjunctive_present_nosotros LIKE '$query%'  OR
      subjunctive_present_vosotros LIKE '$query%'  OR
      subjunctive_present_ellos LIKE '$query%'  OR
      subjunctive_past_yo LIKE '$query%'  OR
      subjunctive_past_tu LIKE '$query%'  OR
      subjunctive_past_el LIKE '$query%'  OR
      subjunctive_past_nosotros LIKE '$query%'  OR
      subjunctive_past_vosotros LIKE '$query%'  OR
      subjunctive_past_ellos LIKE '$query%'
ORDER BY
      (CASE 
          WHEN present_participle = '$query'  OR
              past_participle = '$query'  OR
              indicative_present_yo = '$query'  OR
              indicative_present_tu = '$query'  OR
              indicative_present_el = '$query'  OR
              indicative_present_nosotros = '$query'  OR
              indicative_present_vosotros = '$query'  OR
              indicative_present_ellos = '$query'  OR
              indicative_preterite_yo = '$query'  OR
              indicative_preterite_tu = '$query'  OR 
              indicative_preterite_el = '$query'  OR
              indicative_preterite_nosotros = '$query'  OR
              indicative_preterite_vosotros = '$query'  OR
              indicative_preterite_ellos = '$query'  OR
              indicative_imperfect_yo = '$query'  OR
              indicative_imperfect_tu = '$query'  OR
              indicative_imperfect_el = '$query'  OR
              indicative_imperfect_nosotros = '$query'  OR
              indicative_imperfect_vosotros = '$query'  OR
              indicative_imperfect_ellos = '$query'  OR
              indicative_future_yo = '$query'  OR
              indicative_future_tu = '$query'  OR
              indicative_future_el = '$query'  OR
              indicative_future_nosotros = '$query'  OR
              indicative_future_vosotros = '$query'  OR
              indicative_future_ellos = '$query'  OR
              indicative_conditional_yo = '$query'  OR
              indicative_conditional_tu = '$query'  OR
              indicative_conditional_el = '$query'  OR
              indicative_conditional_nosotros = '$query'  OR
              indicative_conditional_vosotros = '$query'  OR
              indicative_conditional_ellos = '$query'  OR
              imperative_tu = '$query'  OR
              imperative_el = '$query'    OR
              imperative_nosotros = '$query'  OR
              imperative_vosotros = '$query'  OR
              imperative_ellos = '$query'  OR
              subjunctive_present_yo = '$query'  OR
              subjunctive_present_tu = '$query'  OR
              subjunctive_present_el = '$query'  OR
              subjunctive_present_nosotros = '$query'  OR
              subjunctive_present_vosotros = '$query'  OR
              subjunctive_present_ellos = '$query'  OR
              subjunctive_past_yo = '$query'  OR
              subjunctive_past_tu = '$query'  OR
              subjunctive_past_el = '$query'  OR
              subjunctive_past_nosotros = '$query'  OR
              subjunctive_past_vosotros = '$query'  OR
              subjunctive_past_ellos = '$query'
          THEN 0 
          ELSE 1 
      END)
      , word_id
        ''';
  return res;
}
