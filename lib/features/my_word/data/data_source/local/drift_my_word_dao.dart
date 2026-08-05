import 'package:drift/drift.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_word_status.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_words.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
part '../../../../../__generated/features/my_word/data/data_source/local/drift_my_word_dao.g.dart';

@DriftAccessor(tables: [MyWords, MyWordStatus])
class MyWordDao extends DatabaseAccessor<DatabaseProvider>
    with _$MyWordDaoMixin {
  MyWordDao(super.database);
  static const legacyOwner = 'legacy_unowned';

  Future<MyWordTableData?> getMyWordById(String id) {
    return (select(myWords)
          ..where((tbl) =>
              tbl.myWordId.equals(id) & tbl.accountId.equals(legacyOwner)))
        .getSingleOrNull();
  }

  Future<List<MyWordTableData>?> getFilteredMyWordByPage(
      int size, int offset) async {
    return (select(myWords)
          ..where((t) => t.accountId.equals(legacyOwner))
          ..orderBy([
            (t) => OrderingTerm.desc(t.editAt),
          ])
          ..limit(size, offset: offset))
        .get();
  }

  Future<List<String>?> getIdsFilteredMyWordByPage(int size, int offset) async {
    final query = selectOnly(myWords)
      ..addColumns([myWords.myWordId])
      ..where(myWords.accountId.equals(legacyOwner))
      ..orderBy([
        OrderingTerm.desc(myWords.editAt),
      ])
      ..limit(size, offset: offset);

    final rows = await query.get();
    return rows.map((row) => row.read(myWords.myWordId)!).toList();
  }

  Future<void> insertMyWord(
      String id, String headword, String description, String dateTime) async {
    await into(myWords).insert(MyWordsCompanion(
      myWordId: Value(id),
      word: Value(headword),
      contents: Value(description),
      editAt: Value(dateTime),
      accountId: const Value(legacyOwner),
    ));
  }

  Future<int> deleteMyword(String wordId, String editAt) async {
    return await transaction(() async {
      // 子テーブルのデータを削除
      await (delete(myWordStatus)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) &
                tbl.accountId.equals(legacyOwner)))
          .go();
      final rows = await (delete(myWords)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) &
                tbl.accountId.equals(legacyOwner)))
          .go();
      return rows;
    });
  }

  Future<int> updateMyWord(
      String id, String word, String contents, String dateTime) async {
    return await (update(myWords)
          ..where((tbl) =>
              tbl.myWordId.equals(id) & tbl.accountId.equals(legacyOwner)))
        .write(
      MyWordsCompanion(
          myWordId: Value(id),
          word: Value(word),
          contents: Value(contents),
          editAt: Value(dateTime)),
    );
  }

  Future<List<MyWordTableData>> getMyWordsAfter(String dateTime) {
    return (select(myWords)
          ..where((tbl) =>
              tbl.accountId.equals(legacyOwner) &
              tbl.editAt.isBiggerOrEqualValue(dateTime)))
        .get();
  }

  Stream<List<String>> watchMyWordIdsAfter(String dateTime) {
    return (select(myWords)
          ..where((tbl) =>
              tbl.accountId.equals(legacyOwner) &
              tbl.editAt.isBiggerOrEqualValue(dateTime)))
        .watch()
        .map((rows) => rows.map((r) => r.myWordId).toList())
        .distinct();
  }

  Stream<MyWordTableData?> streamMyWordById(String id) {
    return (select(myWords)
          ..where((tbl) =>
              tbl.myWordId.equals(id) & tbl.accountId.equals(legacyOwner)))
        .watchSingleOrNull()
        .distinct();
  }
}
