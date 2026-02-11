import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/dictionaries.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/examples.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:tuple/tuple.dart';

part '../../../../../../__generated/core/infrastructure/database/drift/daos/esp_jpn/dictionary_dao.g.dart';

@DriftAccessor(tables: [EspJpnDictionaries, EspJpnExamples])
class EspjpnDictionaryDao extends DatabaseAccessor<DatabaseProvider>
    with _$EspjpnDictionaryDaoMixin {
  EspjpnDictionaryDao(super.database);

  Future<String?> getContentById(int id) async {
    final res = await (select(espJpnDictionaries)
          ..where((tbl) => tbl.dictionaryId.equals(id))
          ..addColumns([espJpnDictionaries.content]))
        .getSingleOrNull();
    return res?.content;
  }

  Future<String?> getHeadwordById(int id)async {
    final res = await (select(espJpnDictionaries)
          ..where((tbl) => tbl.dictionaryId.equals(id))
          ..addColumns([espJpnDictionaries.headword]))
        .getSingleOrNull();
    return res?.headword;
  }

  Future<String?> getFirstContentByWordId(int wordId) async {
    final query = select(espJpnDictionaries)
      ..where((tbl) => tbl.wordId.equals(wordId))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.dictionaryId)])
      ..limit(1)
      ..addColumns([espJpnDictionaries.content]);
    final res = await query.getSingleOrNull();
    return res?.content;
  }

  Future<String?> getFirstHeadwordByWordId(int wordId) async {
    final query = select(espJpnDictionaries)
      ..where((tbl) => tbl.wordId.equals(wordId))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.dictionaryId)])
      ..limit(1)
      ..addColumns([espJpnDictionaries.headword]);
    final res = await query.getSingleOrNull();
    return res?.headword;
  }

  Future<Map<int, String>> getFirstContentsByWordIds(List<int> wordIds) async {
    if (wordIds.isEmpty) return {};

    final query = select(espJpnDictionaries)
      ..where((tbl) => tbl.wordId.isIn(wordIds))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.dictionaryId)])
      ..addColumns([espJpnDictionaries.wordId, espJpnDictionaries.content]);

    final rows = await query.get();
    final res = <int, String>{};
    for (final row in rows) {
      final content = row.content;
      if (content == null || content.isEmpty) continue;
      res.putIfAbsent(row.wordId, () => content);
    }
    return res;
  }

  Future<Map<int, String>> getFirstHeadwordsByWordIds(List<int> wordIds) async {
    if (wordIds.isEmpty) return {};

    final query = select(espJpnDictionaries)
      ..where((tbl) => tbl.wordId.isIn(wordIds))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.dictionaryId)])
      ..addColumns([espJpnDictionaries.wordId, espJpnDictionaries.headword]);

    final rows = await query.get();
    final res = <int, String>{};
    for (final row in rows) {
      final headword = row.headword;
      if (headword == null || headword.isEmpty) continue;
      res.putIfAbsent(row.wordId, () => headword);
    }
    return res;
  }

  // 特定のword_idに基づいてエントリを取得するメソッド
  Future<List<EspJpnDictionaryTableData>> getDictionaryByWordId(int wordId) {
    return (select(espJpnDictionaries)
          ..where((tbl) => tbl.wordId.equals(wordId)))
        .get();
  }

  // 結合クエリを使用して特定の単語に関連する例文を取得するメソッド
  Future<List<Tuple2<EspJpnDictionaryTableData, EspJpnExampleTableData>>>
      getDictionaryWithExamples(int wordId) {
    final query = select(espJpnDictionaries).join([
      innerJoin(
          espJpnExamples,
          espJpnExamples.dictionaryId
              .equalsExp(espJpnDictionaries.dictionaryId))
    ])
      ..where(espJpnDictionaries.wordId.equals(wordId));
    return query.map((row) {
      return Tuple2(
          row.readTable(espJpnDictionaries), row.readTable(espJpnExamples));
    }).get();
  }
}
