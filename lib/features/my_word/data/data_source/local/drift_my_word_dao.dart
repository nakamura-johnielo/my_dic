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
              tbl.myWordId.equals(id) &
              tbl.accountId.equals(legacyOwner) &
              tbl.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<List<MyWordTableData>?> getFilteredMyWordByPage(
      int size, int offset) async {
    return (select(myWords)
          ..where((t) => t.accountId.equals(legacyOwner) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.desc(t.editAt),
          ])
          ..limit(size, offset: offset))
        .get();
  }

  Future<List<String>?> getIdsFilteredMyWordByPage(int size, int offset) async {
    final query = selectOnly(myWords)
      ..addColumns([myWords.myWordId])
      ..where(myWords.accountId.equals(legacyOwner) & myWords.deletedAt.isNull())
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

  /// Inserts a brand-new MyWord row with `local_revision` starting at 1, so
  /// callers can enqueue a matching outbox mutation in the same transaction.
  Future<MyWordTableData> insertMyWordWithRevision({
    required String id,
    required String word,
    required String contents,
    required String editAt,
  }) async {
    final data = MyWordTableData(
      myWordId: id,
      word: word,
      contents: contents,
      editAt: editAt,
      accountId: legacyOwner,
      localRevision: 1,
    );
    await into(myWords).insert(data);
    return data;
  }

  /// Updates an existing MyWord row and bumps `local_revision` by 1, so
  /// callers can enqueue a matching outbox mutation in the same transaction.
  /// Returns `null` if no row matched.
  Future<MyWordTableData?> updateMyWordWithRevision({
    required String id,
    required String word,
    required String contents,
    required String editAt,
  }) {
    return transaction(() async {
      final existing = await getMyWordById(id);
      if (existing == null) return null;
      final nextRevision = existing.localRevision + 1;
      await (update(myWords)
            ..where((tbl) =>
                tbl.myWordId.equals(id) & tbl.accountId.equals(legacyOwner)))
          .write(
        MyWordsCompanion(
          word: Value(word),
          contents: Value(contents),
          editAt: Value(editAt),
          localRevision: Value(nextRevision),
        ),
      );
      return MyWordTableData(
        myWordId: id,
        word: word,
        contents: contents,
        editAt: editAt,
        accountId: existing.accountId,
        localRevision: nextRevision,
        remoteRevision: existing.remoteRevision,
        deletedAt: existing.deletedAt,
        lastMutationId: existing.lastMutationId,
      );
    });
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

  /// Soft-deletes a MyWord row (`deleted_at` set, `local_revision` bumped)
  /// instead of a hard delete, so the tombstone can be synced and an old
  /// remote update can never resurrect it. The child status row is still
  /// hard-deleted since MyWordStatus is not yet part of the outbox contract.
  /// Returns `null` if no non-deleted row matched.
  Future<MyWordTableData?> tombstoneMyWord(String wordId, String deletedAt) {
    return transaction(() async {
      final existing = await getMyWordById(wordId);
      if (existing == null) return null;
      final nextRevision = existing.localRevision + 1;
      await (delete(myWordStatus)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) &
                tbl.accountId.equals(legacyOwner)))
          .go();
      await (update(myWords)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) &
                tbl.accountId.equals(legacyOwner)))
          .write(
        MyWordsCompanion(
          deletedAt: Value(DateTime.parse(deletedAt)),
          localRevision: Value(nextRevision),
        ),
      );
      return MyWordTableData(
        myWordId: wordId,
        word: existing.word,
        contents: existing.contents,
        editAt: existing.editAt,
        accountId: existing.accountId,
        localRevision: nextRevision,
        remoteRevision: existing.remoteRevision,
        deletedAt: DateTime.parse(deletedAt),
        lastMutationId: existing.lastMutationId,
      );
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
              tbl.deletedAt.isNull() &
              tbl.editAt.isBiggerOrEqualValue(dateTime)))
        .get();
  }

  Stream<List<String>> watchMyWordIdsAfter(String dateTime) {
    return (select(myWords)
          ..where((tbl) =>
              tbl.accountId.equals(legacyOwner) &
              tbl.deletedAt.isNull() &
              tbl.editAt.isBiggerOrEqualValue(dateTime)))
        .watch()
        .map((rows) => rows.map((r) => r.myWordId).toList())
        .distinct();
  }

  Stream<MyWordTableData?> streamMyWordById(String id) {
    return (select(myWords)
          ..where((tbl) =>
              tbl.myWordId.equals(id) &
              tbl.accountId.equals(legacyOwner) &
              tbl.deletedAt.isNull()))
        .watchSingleOrNull()
        .distinct();
  }

  /// Applies a pulled remote snapshot to the local row without bumping
  /// `local_revision` or touching the outbox, so remote apply never looks
  /// like a fresh local edit. `null` per field means "leave untouched" (used
  /// by the sync handler to skip fields with an in-flight local push).
  /// A non-null [deletedAt] tombstones the row (and hard-deletes the child
  /// status row); an already locally-tombstoned row is left untouched by a
  /// non-deletion remote update so a stale remote write can never resurrect it.
  Future<void> applyRemoteFields(
    String wordId, {
    String? word,
    String? contents,
    String? deletedAt,
    required String editAt,
  }) {
    return transaction(() async {
      final existing = await (select(myWords)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) & tbl.accountId.equals(legacyOwner)))
          .getSingleOrNull();

      if (existing != null && existing.deletedAt != null && deletedAt == null) {
        return;
      }

      if (existing == null) {
        await into(myWords).insert(
          MyWordsCompanion.insert(
            myWordId: wordId,
            word: word ?? '',
            contents: Value(contents),
            editAt: editAt,
            accountId: const Value(legacyOwner),
            localRevision: const Value(0),
            deletedAt: Value(
                deletedAt != null ? DateTime.parse(deletedAt) : null),
          ),
        );
        return;
      }

      await (update(myWords)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) & tbl.accountId.equals(legacyOwner)))
          .write(
        MyWordsCompanion(
          word: word != null ? Value(word) : const Value.absent(),
          contents: contents != null ? Value(contents) : const Value.absent(),
          editAt: Value(editAt),
          deletedAt: deletedAt != null
              ? Value(DateTime.parse(deletedAt))
              : const Value.absent(),
        ),
      );

      if (deletedAt != null) {
        await (delete(myWordStatus)
              ..where((tbl) =>
                  tbl.myWordId.equals(wordId) &
                  tbl.accountId.equals(legacyOwner)))
            .go();
      }
    });
  }
}
