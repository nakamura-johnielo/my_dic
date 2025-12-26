import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_word.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_word_status.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';


part '../../../../../../__generated/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_word_dao.g.dart';

@DriftAccessor(tables: [JpnEspWords, JpnEspWordStatus])
class JpnEspWordDao extends DatabaseAccessor<DatabaseProvider>
    with _$JpnEspWordDaoMixin {
  JpnEspWordDao(super.database);

  Future<JpnEspWordTableData?> getDictionaryByWordId(int wordId) {
    return (select(jpnEspWords)..where((tbl) => tbl.wordId.equals(wordId)))
        .getSingleOrNull();
  }

  Future<void> insertWord(Insertable<JpnEspWordTableData> tableName) =>
      into(jpnEspWords).insert(tableName);

  Future<void> updateWord(Insertable<JpnEspWordTableData> tableName) =>
      update(jpnEspWords).replace(tableName);

  Future<void> deleteWord(Insertable<JpnEspWordTableData> tableName) =>
      delete(jpnEspWords).delete(tableName);

  Future<List<JpnEspWordTableData>?> getWordsByWord(
      String searchWord, int size, int currentPage) async {
    final int offset = size * currentPage; // ページ番号に基づいてスキップする件数を計算

    return (select(jpnEspWords)
          ..where((tbl) => tbl.word.like('$searchWord%'))
          ..limit(size, offset: offset)) // limit と offset を追加
        .get();
  }
}
