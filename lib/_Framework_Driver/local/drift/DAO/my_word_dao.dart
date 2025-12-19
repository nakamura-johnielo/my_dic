import 'package:drift/drift.dart';
import 'package:my_dic/_Framework_Driver/local/drift/Entity/my_word_status.dart';
import 'package:my_dic/_Framework_Driver/local/drift/Entity/my_words.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart';
part '../../../../__generated/_Framework_Driver/Database/drift/DAO/my_word_dao.g.dart';

@DriftAccessor(tables: [MyWords, MyWordStatus])
class MyWordDao extends DatabaseAccessor<DatabaseProvider>
    with _$MyWordDaoMixin {
  MyWordDao(super.database);

  Future<MyWord?> getMyWordById(int id) {
    return (select(myWords)..where((tbl) => tbl.myWordId.equals(id)))
        .getSingleOrNull();
  }

  Future<List<MyWord>?> getFilteredMyWordByPage(int size, int offset) async {
    return (select(myWords)
          ..orderBy([(t) => OrderingTerm.desc(t.myWordId)])
          ..limit(size, offset: offset))
        .get();
  }

  Future<int> insertMyWord(
      String headword, String description, String dateTime) async {
    return await into(myWords).insert(MyWordsCompanion(
      word: Value(headword),
      contents: Value(description),
      editAt: Value(dateTime),
    ));
  }

  Future<void> deleteMyword(int wordId, String editAt) async {
    await transaction(() async {
      // 子テーブルのデータを削除
      await (delete(myWordStatus)..where((tbl) => tbl.myWordId.equals(wordId)))
          .go();
      await (delete(myWords)..where((tbl) => tbl.myWordId.equals(wordId))).go();
    });
  }

  /* Future<void> updateMyWord(Insertable<MyWord> tableName) =>
      update(myWords).replace(tableName); */

  Future<void> updateMyWord(
      int id, String word, String contents, String dateTime) async {
    await (update(myWords)..where((tbl) => tbl.myWordId.equals(id))).write(
      MyWordsCompanion(
          myWordId: Value(id),
          word: Value(word),
          contents: Value(contents),
          editAt: Value(dateTime)),
    );
  }
}
