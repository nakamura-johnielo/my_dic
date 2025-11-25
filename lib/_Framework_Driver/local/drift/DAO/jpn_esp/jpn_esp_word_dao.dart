import 'package:drift/drift.dart';
import 'package:my_dic/_Framework_Driver/local/drift/Entity/jpn-esp/jpn_esp_word.dart';
import 'package:my_dic/_Framework_Driver/local/drift/Entity/jpn-esp/jpn_esp_word_status.dart';
import 'package:my_dic/_Framework_Driver/local/drift/database_provider.dart';

part '../../../../../__generated/_Framework_Driver/Database/drift/DAO/jpn_esp/jpn_esp_word_dao.g.dart';

@DriftAccessor(tables: [JpnEspWords, JpnEspWordStatus])
class JpnEspWordDao extends DatabaseAccessor<DatabaseProvider>
    with _$JpnEspWordDaoMixin {
  JpnEspWordDao(super.database);

  Future<JpnEspWord?> getDictionaryByWordId(int wordId) {
    return (select(jpnEspWords)..where((tbl) => tbl.wordId.equals(wordId)))
        .getSingleOrNull();
  }

  Future<void> insertWord(Insertable<JpnEspWord> tableName) =>
      into(jpnEspWords).insert(tableName);

  Future<void> updateWord(Insertable<JpnEspWord> tableName) =>
      update(jpnEspWords).replace(tableName);

  Future<void> deleteWord(Insertable<JpnEspWord> tableName) =>
      delete(jpnEspWords).delete(tableName);

  Future<List<JpnEspWord>?> getWordsByWord(
      String searchWord, int size, int currentPage) async {
    final int offset = size * currentPage; // ページ番号に基づいてスキップする件数を計算

    return (select(jpnEspWords)
          ..where((tbl) => tbl.word.like('$searchWord%'))
          ..limit(size, offset: offset)) // limit と offset を追加
        .get();
  }
}
