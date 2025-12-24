import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/table/esp_jpn/words.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart';

part '../../../../../../__generated/core/infrastructure/database/dao/local/esp_jpn/esp_jpn_word_dao.g.dart';
@DriftAccessor(tables: [EspJpnWords])
class EspJpnWordDao extends DatabaseAccessor<DatabaseProvider> with _$EspJpnWordDaoMixin {
  EspJpnWordDao(super.database);

  Future<EspJpnWordTableData?> getDictionaryByWordId(int wordId) {
    return (select(espJpnWords)..where((tbl) => tbl.wordId.equals(wordId)))
        .getSingleOrNull();
  }

  Future<void> insertWord(Insertable<EspJpnWordTableData> tableName) =>
      into(espJpnWords).insert(tableName);

  Future<void> updateWord(Insertable<EspJpnWordTableData> tableName) =>
      update(espJpnWords).replace(tableName);

  Future<void> deleteWord(Insertable<EspJpnWordTableData> tableName) =>
      delete(espJpnWords).delete(tableName);

  Future<List<EspJpnWordTableData>?> getWordsByWord(String searchWord) async {
    return (select(espJpnWords)..where((tbl) => tbl.word.like('$searchWord%'))).get();
  }

  Future<List<EspJpnWordTableData>?> getWordsByWordByPage(
      String searchWord, int size, int currentPage) async {
    final int offset = size * currentPage; // ページ番号に基づいてスキップする件数を計算

    return (select(espJpnWords)
          ..where((tbl) => tbl.word.like('$searchWord%'))
          ..limit(size, offset: offset)) // limit と offset を追加
        .get();
  }
}
