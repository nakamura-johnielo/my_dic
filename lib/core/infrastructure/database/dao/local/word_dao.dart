import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/table/words.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart';
part '../../../../../__generated/core/infrastructure/database/dao/local/word_dao.g.dart';

@DriftAccessor(tables: [Words])
class WordDao extends DatabaseAccessor<DatabaseProvider> with _$WordDaoMixin {
  WordDao(super.database);

  Future<WordTableData?> getDictionaryByWordId(int wordId) {
    return (select(words)..where((tbl) => tbl.wordId.equals(wordId)))
        .getSingleOrNull();
  }

  Future<void> insertWord(Insertable<WordTableData> tableName) =>
      into(words).insert(tableName);

  Future<void> updateWord(Insertable<WordTableData> tableName) =>
      update(words).replace(tableName);

  Future<void> deleteWord(Insertable<WordTableData> tableName) =>
      delete(words).delete(tableName);

  Future<List<WordTableData>?> getWordsByWord(String searchWord) async {
    return (select(words)..where((tbl) => tbl.word.like('$searchWord%'))).get();
  }

  Future<List<WordTableData>?> getWordsByWordByPage(
      String searchWord, int size, int currentPage) async {
    final int offset = size * currentPage; // ページ番号に基づいてスキップする件数を計算

    return (select(words)
          ..where((tbl) => tbl.word.like('$searchWord%'))
          ..limit(size, offset: offset)) // limit と offset を追加
        .get();
  }
}
