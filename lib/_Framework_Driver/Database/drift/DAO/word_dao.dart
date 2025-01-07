import 'package:drift/drift.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/words.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/database_provider.dart';
part '../../../../__generated/_Framework_Driver/Database/drift/DAO/word_dao.g.dart';

@DriftAccessor(tables: [Words])
class WordDao extends DatabaseAccessor<DatabaseProvider> with _$WordDaoMixin {
  WordDao(super.database);

  Future<Word?> getDictionaryByWordId(int wordId) {
    return (select(words)..where((tbl) => tbl.wordId.equals(wordId)))
        .getSingleOrNull();
  }

  Future<void> insertWord(Insertable<Word> tableName) =>
      into(words).insert(tableName);

  Future<void> updateWord(Insertable<Word> tableName) =>
      update(words).replace(tableName);

  Future<void> deleteWord(Insertable<Word> tableName) =>
      delete(words).delete(tableName);

  Future<List<Word>?> getWordsByWord(String searchWord) async {
    return (select(words)..where((tbl) => tbl.word.like('$searchWord%'))).get();
  }
}
