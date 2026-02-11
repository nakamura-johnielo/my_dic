import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_dictionaries.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';


part '../../../../../../__generated/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_dictionary_dao.g.dart';

@DriftAccessor(tables: [JpnEspDictionaries])
class JpnEspDictionaryDao extends DatabaseAccessor<DatabaseProvider>
    with _$JpnEspDictionaryDaoMixin {
  JpnEspDictionaryDao(super.database);
  // 特定のword_idに基づいてエントリを取得するメソッド
  Future<List<JpnEspDictionaryTableData>> getDictionaryByWordId(int wordId) {
    return (select(jpnEspDictionaries)
          ..where((tbl) => tbl.wordId.equals(wordId)))
        .get();
  }

  
  Future<Map<int, String>> getFirstContentsByWordIds(List<int> wordIds) async {
    if (wordIds.isEmpty) return {};

    final query = select(jpnEspDictionaries)
      ..where((tbl) => tbl.wordId.isIn(wordIds))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.dictionaryId)])
      ..addColumns([jpnEspDictionaries.wordId, jpnEspDictionaries.content]);

    final rows = await query.get();
    final res = <int, String>{};
    for (final row in rows) {
      final content = row.content;
      if (content == null || content.isEmpty) continue;
      res.putIfAbsent(row.wordId, () => content);
    }
    return res;
  }
}


