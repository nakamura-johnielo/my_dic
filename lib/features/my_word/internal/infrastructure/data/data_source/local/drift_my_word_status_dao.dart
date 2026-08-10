import 'package:drift/drift.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/my_word_status.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
part '../../../../../../../__generated/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_status_dao.g.dart';

@DriftAccessor(tables: [MyWordStatus])
class MyWordStatusDao extends DatabaseAccessor<DatabaseProvider>
    with _$MyWordStatusDaoMixin {
  MyWordStatusDao(super.database);
  static const legacyOwner = guestAccountScope;

  Future<void> updateStatus(
    final String myWordId,
    final int? isLearned,
    final int? isBookmarked,
    final int? hasNote,
    final String editAt,
  ) async {
    AppLogger.print("update");
    await (update(myWordStatus)
          ..where((t) =>
              t.myWordId.equals(myWordId) & t.accountId.equals(legacyOwner)))
        .write(
      MyWordStatusCompanion(
        isLearned: isLearned != null ? Value(isLearned) : Value.absent(),
        isBookmarked:
            isBookmarked != null ? Value(isBookmarked) : Value.absent(),
        hasNote: hasNote != null ? Value(hasNote) : Value.absent(),
        editAt: Value(editAt),
      ),
    );
  }

  Future<void> insertStatus(MyWordStatusTableData data) async {
    await into(myWordStatus).insert(data);
    AppLogger.print("insert");
  }

  Future<bool> exist(String id) async {
    final existingColum = await (select(myWordStatus)
          ..where(
              (t) => t.myWordId.equals(id) & t.accountId.equals(legacyOwner)))
        .getSingleOrNull();
    return existingColum != null ? true : false;
  }

  Stream<MyWordStatusTableData?> watchWordStatus(
      String wordId, String accountId) {
    return (select(myWordStatus)
          ..where((tbl) =>
              tbl.myWordId.equals(wordId) & tbl.accountId.equals(accountId)))
        .watchSingleOrNull()
        .distinct();
  }

  Future<MyWordStatusTableData?> getWordStatus(
      String wordId, String accountId) async {
    final data = await (select(myWordStatus)
          ..where((tbl) =>
              tbl.myWordId.equals(wordId) & tbl.accountId.equals(accountId)))
        .getSingleOrNull();
    return data;
  }

  /// Returns every row for [accountId]. Used by the guest-data
  /// detector/migration, which needs the full set rather than a single row.
  Future<List<MyWordStatusTableData>> getAllByAccountId(String accountId) {
    return (select(myWordStatus)..where((t) => t.accountId.equals(accountId)))
        .get();
  }

  /// Reassigns a status row's account scope in place (e.g. guest -> a
  /// signed-in account), bumping `local_revision` so a matching outbox
  /// mutation can be enqueued. Returns `null` if no row matched at
  /// [fromAccountId] or a row already exists at [toAccountId] (the caller
  /// should merge/skip instead).
  Future<MyWordStatusTableData?> reassignAccountId(
      String myWordId, String fromAccountId, String toAccountId) {
    return transaction(() async {
      final existing = await getWordStatus(myWordId, fromAccountId);
      if (existing == null) return null;
      final conflict = await getWordStatus(myWordId, toAccountId);
      if (conflict != null) return null;
      await (update(myWordStatus)
            ..where((t) =>
                t.myWordId.equals(myWordId) &
                t.accountId.equals(fromAccountId)))
          .write(MyWordStatusCompanion(
        accountId: Value(toAccountId),
        localRevision: Value(existing.localRevision + 1),
      ));
      return getWordStatus(myWordId, toAccountId);
    });
  }

  Future<void> deleteRow(String myWordId, String accountId) async {
    await (delete(myWordStatus)
          ..where((t) =>
              t.myWordId.equals(myWordId) & t.accountId.equals(accountId)))
        .go();
  }

  /// Persists the remote transaction acknowledgement only when no later
  /// local write has superseded the leased revision.
  Future<bool> acknowledgeRemoteMutation({
    required String myWordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  }) async {
    final changed = await (update(myWordStatus)
          ..where((t) =>
              t.myWordId.equals(myWordId) &
              t.accountId.equals(accountId) &
              t.localRevision.equals(localRevision)))
        .write(MyWordStatusCompanion(
      remoteRevision: Value(remoteRevision),
      lastMutationId: Value(lastMutationId),
    ));
    return changed == 1;
  }

  /// Upserts the status row and bumps `local_revision` by 1 (new rows start
  /// at 1), so callers can enqueue a matching outbox mutation in the same
  /// transaction. `null` per field means "leave unchanged" on an update.
  Future<MyWordStatusTableData> applyStatusPatch(
    String myWordId,
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    String editAt,
    String accountId,
  ) {
    return transaction(() async {
      final existing = await getWordStatus(myWordId, accountId);
      final nextRevision = (existing?.localRevision ?? 0) + 1;
      if (existing == null) {
        await into(myWordStatus).insert(
          MyWordStatusCompanion.insert(
            myWordId: myWordId,
            isLearned: Value(isLearned ?? 0),
            isBookmarked: Value(isBookmarked ?? 0),
            hasNote: Value(hasNote ?? 0),
            editAt: editAt,
            accountId: Value(accountId),
            localRevision: Value(nextRevision),
          ),
        );
      } else {
        await (update(myWordStatus)
              ..where((t) =>
                  t.myWordId.equals(myWordId) & t.accountId.equals(accountId)))
            .write(
          MyWordStatusCompanion(
            isLearned:
                isLearned != null ? Value(isLearned) : const Value.absent(),
            isBookmarked: isBookmarked != null
                ? Value(isBookmarked)
                : const Value.absent(),
            hasNote: hasNote != null ? Value(hasNote) : const Value.absent(),
            editAt: Value(editAt),
            localRevision: Value(nextRevision),
          ),
        );
      }
      final updated = await getWordStatus(myWordId, accountId);
      if (updated == null) {
        throw StateError('MyWordStatus was not persisted: $myWordId');
      }
      return updated;
    });
  }

  /// Applies a pulled remote snapshot without bumping `local_revision` or
  /// touching the outbox. `null` per field means "leave untouched" (used by
  /// the sync handler to skip fields with an in-flight local push).
  Future<void> applyRemoteFields(
    String myWordId, {
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    required String editAt,
    required String accountId,
    String? remoteRevision,
    String? lastMutationId,
  }) {
    return transaction(() async {
      final existing = await getWordStatus(myWordId, accountId);
      if (existing == null) {
        await into(myWordStatus).insert(
          MyWordStatusCompanion.insert(
            myWordId: myWordId,
            isLearned: Value(isLearned ?? 0),
            isBookmarked: Value(isBookmarked ?? 0),
            hasNote: Value(hasNote ?? 0),
            editAt: editAt,
            accountId: Value(accountId),
            localRevision: const Value(0),
            remoteRevision: Value(remoteRevision),
            lastMutationId: Value(lastMutationId),
          ),
        );
        return;
      }
      await (update(myWordStatus)
            ..where((t) =>
                t.myWordId.equals(myWordId) & t.accountId.equals(accountId)))
          .write(
        MyWordStatusCompanion(
          isLearned:
              isLearned != null ? Value(isLearned) : const Value.absent(),
          isBookmarked:
              isBookmarked != null ? Value(isBookmarked) : const Value.absent(),
          hasNote: hasNote != null ? Value(hasNote) : const Value.absent(),
          editAt: Value(editAt),
          remoteRevision: remoteRevision != null
              ? Value(remoteRevision)
              : const Value.absent(),
          lastMutationId: lastMutationId != null
              ? Value(lastMutationId)
              : const Value.absent(),
        ),
      );
    });
  }

  /// Runs [action] within a single Drift transaction so callers can combine
  /// a status row write with an outbox mutation atomically.
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      transaction(action);
}
