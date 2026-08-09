import 'package:drift/drift.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_word_status.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_words.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
part '../../../../../__generated/features/my_word/data/data_source/local/drift_my_word_dao.g.dart';

/// Raw, read-only result of the account-scoped MyWord/status projection.
class MyWordItemRow {
  const MyWordItemRow({required this.word, required this.status});

  final MyWordTableData word;
  final MyWordStatusTableData? status;
}

@DriftAccessor(tables: [MyWords, MyWordStatus])
class MyWordDao extends DatabaseAccessor<DatabaseProvider>
    with _$MyWordDaoMixin {
  MyWordDao(super.database);
  static const legacyOwner = guestAccountScope;

  Future<MyWordTableData?> getMyWordById(String id, String accountId) {
    return (select(myWords)
          ..where((tbl) =>
              tbl.myWordId.equals(id) &
              tbl.accountId.equals(accountId) &
              tbl.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<List<MyWordTableData>?> getFilteredMyWordByPage(
      int size, int offset, String accountId) async {
    return (select(myWords)
          ..where((t) => t.accountId.equals(accountId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.desc(t.editAt),
          ])
          ..limit(size, offset: offset))
        .get();
  }

  Future<List<String>?> getIdsFilteredMyWordByPage(
      int size, int offset, String accountId) async {
    final query = selectOnly(myWords)
      ..addColumns([myWords.myWordId])
      ..where(myWords.accountId.equals(accountId) & myWords.deletedAt.isNull())
      ..orderBy([
        OrderingTerm.desc(myWords.editAt),
      ])
      ..limit(size, offset: offset);

    final rows = await query.get();
    return rows.map((row) => row.read(myWords.myWordId)!).toList();
  }

  /// Returns every non-deleted row for [accountId]. Used by the guest-data
  /// detector/migration, which needs the full set rather than a page.
  Future<List<MyWordTableData>> getAllByAccountId(String accountId) {
    return (select(myWords)
          ..where((t) => t.accountId.equals(accountId) & t.deletedAt.isNull()))
        .get();
  }

  /// Reassigns a row's account scope in place (e.g. guest -> a signed-in
  /// account), bumping `local_revision` so a matching outbox mutation can be
  /// enqueued. Returns `null` if no row matched at [fromAccountId] or a row
  /// already exists at [toAccountId] (the caller should merge/skip instead).
  Future<MyWordTableData?> reassignAccountId(
      String wordId, String fromAccountId, String toAccountId) {
    return transaction(() async {
      final existing = await getMyWordById(wordId, fromAccountId);
      if (existing == null) return null;
      final conflict = await getMyWordById(wordId, toAccountId);
      if (conflict != null) return null;
      await (update(myWords)
            ..where((t) =>
                t.myWordId.equals(wordId) & t.accountId.equals(fromAccountId)))
          .write(MyWordsCompanion(
        accountId: Value(toAccountId),
        localRevision: Value(existing.localRevision + 1),
      ));
      return getMyWordById(wordId, toAccountId);
    });
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
    required String accountId,
  }) async {
    final data = MyWordTableData(
      myWordId: id,
      word: word,
      contents: contents,
      editAt: editAt,
      accountId: accountId,
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
    required String accountId,
  }) {
    return transaction(() async {
      final existing = await getMyWordById(id, accountId);
      if (existing == null) return null;
      final nextRevision = existing.localRevision + 1;
      await (update(myWords)
            ..where((tbl) =>
                tbl.myWordId.equals(id) & tbl.accountId.equals(accountId)))
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
  Future<MyWordTableData?> tombstoneMyWord(
      String wordId, String deletedAt, String accountId) {
    return transaction(() async {
      final existing = await getMyWordById(wordId, accountId);
      if (existing == null) return null;
      final nextRevision = existing.localRevision + 1;
      await (delete(myWordStatus)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) & tbl.accountId.equals(accountId)))
          .go();
      await (update(myWords)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) & tbl.accountId.equals(accountId)))
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

  Stream<MyWordTableData?> streamMyWordById(String id, String accountId) {
    return (select(myWords)
          ..where((tbl) =>
              tbl.myWordId.equals(id) &
              tbl.accountId.equals(accountId) &
              tbl.deletedAt.isNull()))
        .watchSingleOrNull()
        .distinct();
  }

  /// Watches one non-deleted MyWord together with only the status belonging
  /// to the same account. A missing (or tombstoned) status is deliberately
  /// returned as null for the read adapter to normalize without a write.
  Stream<MyWordItemRow?> watchMyWordItemRow(String id, String accountId) {
    final query = select(myWords).join([
      leftOuterJoin(
        myWordStatus,
        myWordStatus.myWordId.equalsExp(myWords.myWordId) &
            myWordStatus.accountId.equalsExp(myWords.accountId),
      ),
    ])
      ..where(
        myWords.myWordId.equals(id) &
            myWords.accountId.equals(accountId) &
            myWords.deletedAt.isNull(),
      );

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      final row = rows.single;
      return MyWordItemRow(
        word: row.readTable(myWords),
        status: row.readTableOrNull(myWordStatus),
      );
    });
  }

  /// Persists the remote transaction acknowledgement only when no later
  /// local write has superseded the leased revision.
  Future<bool> acknowledgeRemoteMutation({
    required String wordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  }) async {
    final changed = await (update(myWords)
          ..where((t) =>
              t.myWordId.equals(wordId) &
              t.accountId.equals(accountId) &
              t.localRevision.equals(localRevision)))
        .write(MyWordsCompanion(
      remoteRevision: Value(remoteRevision),
      lastMutationId: Value(lastMutationId),
    ));
    return changed == 1;
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
    required String accountId,
    String? remoteRevision,
    String? lastMutationId,
  }) {
    return transaction(() async {
      final existing = await (select(myWords)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) & tbl.accountId.equals(accountId)))
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
            accountId: Value(accountId),
            localRevision: const Value(0),
            remoteRevision: Value(remoteRevision),
            lastMutationId: Value(lastMutationId),
            deletedAt:
                Value(deletedAt != null ? DateTime.parse(deletedAt) : null),
          ),
        );
        return;
      }

      await (update(myWords)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) & tbl.accountId.equals(accountId)))
          .write(
        MyWordsCompanion(
          word: word != null ? Value(word) : const Value.absent(),
          contents: contents != null ? Value(contents) : const Value.absent(),
          editAt: Value(editAt),
          deletedAt: deletedAt != null
              ? Value(DateTime.parse(deletedAt))
              : const Value.absent(),
          remoteRevision: remoteRevision != null
              ? Value(remoteRevision)
              : const Value.absent(),
          lastMutationId: lastMutationId != null
              ? Value(lastMutationId)
              : const Value.absent(),
        ),
      );

      if (deletedAt != null) {
        await (delete(myWordStatus)
              ..where((tbl) =>
                  tbl.myWordId.equals(wordId) &
                  tbl.accountId.equals(accountId)))
            .go();
      }
    });
  }
}
