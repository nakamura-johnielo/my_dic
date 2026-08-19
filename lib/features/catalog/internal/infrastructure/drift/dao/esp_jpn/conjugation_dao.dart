import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/conjugations.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/catalog_like_pattern.dart';

part '../../../../../../../__generated/features/catalog/internal/infrastructure/drift/dao/esp_jpn/conjugation_dao.g.dart';

@DriftAccessor(tables: [EspConjugations])
class ConjugationDao extends DatabaseAccessor<DatabaseProvider>
    with _$ConjugationDaoMixin {
  ConjugationDao(super.database);

  Future<String?> getMeaningById(int id) async {
    final query = select(espConjugations)
      ..where((table) => table.wordId.equals(id))
      ..addColumns([espConjugations.meaning]);
    return (await query.getSingleOrNull())?.meaning;
  }

  Future<Map<int, String>> getMeaningsByWordIds(List<int> wordIds) async {
    if (wordIds.isEmpty) return {};
    final rows = await (select(espConjugations)
          ..where((table) => table.wordId.isIn(wordIds))
          ..addColumns([espConjugations.wordId, espConjugations.meaning]))
        .get();
    return {
      for (final row in rows)
        if (row.meaning case final meaning? when meaning.isNotEmpty)
          row.wordId: meaning,
    };
  }

  Future<bool> exists(int wordId) async =>
      await (select(espConjugations)
            ..where((table) => table.wordId.equals(wordId))
            ..addColumns([espConjugations.wordId]))
          .getSingleOrNull() !=
      null;

  Future<EspConjugationTableData?> getConjugationById(int id) =>
      (select(espConjugations)..where((table) => table.wordId.equals(id)))
          .getSingleOrNull();

  Future<List<EspConjugationTableData>> getConjugationByWordWithPage(
    String word,
    int size,
    int requiredPage,
  ) =>
      _search(word, size, requiredPage, includeHeadword: false);

  Future<List<EspConjugationTableData>> getConjugationInAllTableByWordWithPage(
    String word,
    int size,
    int requiredPage,
  ) =>
      _search(word, size, requiredPage, includeHeadword: true);

  Future<List<EspConjugationTableData>> _search(
    String text,
    int size,
    int page, {
    required bool includeHeadword,
  }) async {
    final rows = await customSelect(
      _searchSql(includeHeadword: includeHeadword),
      variables: [
        Variable.withString(catalogPrefixLikePattern(text)),
        Variable.withString(text),
        Variable.withInt(size),
        Variable.withInt(size * page),
      ],
      readsFrom: {espConjugations},
    ).get();
    return rows
        .map((row) => espConjugations.map(row.data))
        .toList(growable: false);
  }
}

// この許可リストは、レガシーカスタムクエリで使用する SQL 識別子の唯一のソースである。
// ユーザー制御の値は常にバインド変数として渡される。
const _formColumns = <String>[
  'present_participle',
  'past_participle',
  'indicative_present_yo',
  'indicative_present_tu',
  'indicative_present_el',
  'indicative_present_nosotros',
  'indicative_present_vosotros',
  'indicative_present_ellos',
  'indicative_preterite_yo',
  'indicative_preterite_tu',
  'indicative_preterite_el',
  'indicative_preterite_nosotros',
  'indicative_preterite_vosotros',
  'indicative_preterite_ellos',
  'indicative_imperfect_yo',
  'indicative_imperfect_tu',
  'indicative_imperfect_el',
  'indicative_imperfect_nosotros',
  'indicative_imperfect_vosotros',
  'indicative_imperfect_ellos',
  'indicative_future_yo',
  'indicative_future_tu',
  'indicative_future_el',
  'indicative_future_nosotros',
  'indicative_future_vosotros',
  'indicative_future_ellos',
  'indicative_conditional_yo',
  'indicative_conditional_tu',
  'indicative_conditional_el',
  'indicative_conditional_nosotros',
  'indicative_conditional_vosotros',
  'indicative_conditional_ellos',
  'imperative_tu',
  'imperative_el',
  'imperative_nosotros',
  'imperative_vosotros',
  'imperative_ellos',
  'subjunctive_present_yo',
  'subjunctive_present_tu',
  'subjunctive_present_el',
  'subjunctive_present_nosotros',
  'subjunctive_present_vosotros',
  'subjunctive_present_ellos',
  'subjunctive_past_yo',
  'subjunctive_past_tu',
  'subjunctive_past_el',
  'subjunctive_past_nosotros',
  'subjunctive_past_vosotros',
  'subjunctive_past_ellos',
];

String _searchSql({required bool includeHeadword}) {
  final searchColumns =
      includeHeadword ? const ['word', ..._formColumns] : _formColumns;
  final projectedForms = _formColumns.map(
    (column) =>
        "CASE WHEN $column LIKE ?1 ESCAPE '!' THEN $column ELSE '' END AS $column",
  );
  final prefixConditions =
      searchColumns.map((column) => "$column LIKE ?1 ESCAPE '!'").join(' OR ');
  final exactConditions =
      searchColumns.map((column) => '$column = ?2').join(' OR ');
  return '''
SELECT word_id, word, meaning, ${projectedForms.join(', ')}
FROM conjugations
WHERE $prefixConditions
ORDER BY CASE WHEN $exactConditions THEN 0 ELSE 1 END, word_id
LIMIT ?3 OFFSET ?4
''';
}
