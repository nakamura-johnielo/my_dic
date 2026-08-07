import 'package:drift/drift.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_word_status.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
part '../../../../../__generated/features/my_word/data/data_source/local/drift_my_word_status_dao.g.dart';

@DriftAccessor(tables: [MyWordStatus])
class MyWordStatusDao extends DatabaseAccessor<DatabaseProvider>
    with _$MyWordStatusDaoMixin {
  MyWordStatusDao(super.database);
  static const legacyOwner = 'legacy_unowned';

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

  Stream<MyWordStatusTableData?> watchWordStatus(String wordId) {
    return (select(myWordStatus)
          ..where((tbl) =>
              tbl.myWordId.equals(wordId) & tbl.accountId.equals(legacyOwner)))
        .watchSingleOrNull()
        .distinct();
  }

  Future<MyWordStatusTableData?> getWordStatus(String wordId) async {
    final data = await (select(myWordStatus)
          ..where((tbl) =>
              tbl.myWordId.equals(wordId) & tbl.accountId.equals(legacyOwner)))
        .getSingleOrNull();
    return data;
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
  ) {
    return transaction(() async {
      final existing = await getWordStatus(myWordId);
      final nextRevision = (existing?.localRevision ?? 0) + 1;
      if (existing == null) {
        await into(myWordStatus).insert(
          MyWordStatusCompanion.insert(
            myWordId: myWordId,
            isLearned: Value(isLearned ?? 0),
            isBookmarked: Value(isBookmarked ?? 0),
            hasNote: Value(hasNote ?? 0),
            editAt: editAt,
            accountId: const Value(legacyOwner),
            localRevision: Value(nextRevision),
          ),
        );
      } else {
        await (update(myWordStatus)
              ..where((t) =>
                  t.myWordId.equals(myWordId) & t.accountId.equals(legacyOwner)))
            .write(
          MyWordStatusCompanion(
            isLearned: isLearned != null ? Value(isLearned) : const Value.absent(),
            isBookmarked:
                isBookmarked != null ? Value(isBookmarked) : const Value.absent(),
            hasNote: hasNote != null ? Value(hasNote) : const Value.absent(),
            editAt: Value(editAt),
            localRevision: Value(nextRevision),
          ),
        );
      }
      final updated = await getWordStatus(myWordId);
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
  }) {
    return transaction(() async {
      final existing = await getWordStatus(myWordId);
      if (existing == null) {
        await into(myWordStatus).insert(
          MyWordStatusCompanion.insert(
            myWordId: myWordId,
            isLearned: Value(isLearned ?? 0),
            isBookmarked: Value(isBookmarked ?? 0),
            hasNote: Value(hasNote ?? 0),
            editAt: editAt,
            accountId: const Value(legacyOwner),
            localRevision: const Value(0),
          ),
        );
        return;
      }
      await (update(myWordStatus)
            ..where((t) =>
                t.myWordId.equals(myWordId) & t.accountId.equals(legacyOwner)))
          .write(
        MyWordStatusCompanion(
          isLearned: isLearned != null ? Value(isLearned) : const Value.absent(),
          isBookmarked:
              isBookmarked != null ? Value(isBookmarked) : const Value.absent(),
          hasNote: hasNote != null ? Value(hasNote) : const Value.absent(),
          editAt: Value(editAt),
        ),
      );
    });
  }

  /// Runs [action] within a single Drift transaction so callers can combine
  /// a status row write with an outbox mutation atomically.
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      transaction(action);
}
