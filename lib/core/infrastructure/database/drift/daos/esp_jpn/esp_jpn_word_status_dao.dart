import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/word_status.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/utils/logger.dart';

part '../../../../../../__generated/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.g.dart';

@DriftAccessor(tables: [EspJpnWordStatus])
class EspJpnWordStatusDao extends DatabaseAccessor<DatabaseProvider>
    with _$EspJpnWordStatusDaoMixin {
  EspJpnWordStatusDao(super.database);
  static const legacyOwner = guestAccountScope;

  Stream<EspJpnWordStatusTableData?> watchWordStatus(
      int wordId, String accountId) {
    return (select(espJpnWordStatus)
          ..where((tbl) =>
              tbl.wordId.equals(wordId) & tbl.accountId.equals(accountId)))
        .watchSingleOrNull()
        .distinct();
  }

  Stream<List<int>> watchChangedWordIdsWithFilter(
      DateTime since, String accountId) {
    return (select(espJpnWordStatus)
          ..where((tbl) =>
              tbl.accountId.equals(accountId) &
              tbl.editAt.isBiggerOrEqualValue(since.toIso8601String())))
        .watch()
        .map((rows) => rows.map((row) => row.wordId).toList())
        .distinct();
  }

  Future<EspJpnWordStatusTableData> applyStatusPatch(
    int wordId,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    String editAt,
    String accountId,
  ) async {
    return transaction(() async {
      final existing = await getStatusById(wordId, accountId);
      final nextRevision = (existing?.localRevision ?? 0) + 1;
      if (existing == null) {
        await into(espJpnWordStatus).insert(
          EspJpnWordStatusCompanion.insert(
            wordId: wordId,
            isLearned: Value(isLearned == true ? 1 : 0),
            isBookmarked: Value(isBookmarked == true ? 1 : 0),
            hasNote: Value(hasNote == true ? 1 : 0),
            editAt: editAt,
            accountId: Value(accountId),
            localRevision: Value(nextRevision),
          ),
        );
      } else {
        await (update(espJpnWordStatus)
              ..where((t) =>
                  t.wordId.equals(wordId) & t.accountId.equals(accountId)))
            .write(
          EspJpnWordStatusCompanion(
            isLearned: isLearned != null
                ? Value(isLearned ? 1 : 0)
                : const Value.absent(),
            isBookmarked: isBookmarked != null
                ? Value(isBookmarked ? 1 : 0)
                : const Value.absent(),
            hasNote:
                hasNote != null ? Value(hasNote ? 1 : 0) : const Value.absent(),
            editAt: Value(editAt),
            localRevision: Value(nextRevision),
          ),
        );
      }

      final updated = await getStatusById(wordId, accountId);
      if (updated == null) {
        throw StateError('Esp-Jpn word status was not persisted: $wordId');
      }
      AppLogger.print("update");
      return updated;
    });
  }

  Future<EspJpnWordStatusTableData?> getStatusById(
      int wordId, String accountId) {
    return (select(espJpnWordStatus)
          ..where((tbl) =>
              tbl.wordId.equals(wordId) & tbl.accountId.equals(accountId)))
        .getSingleOrNull();
  }

  Future<List<EspJpnWordStatusTableData>> getWordStatusAfter(
      DateTime datetime, String accountId) {
    return (select(espJpnWordStatus)
          ..where((tbl) =>
              tbl.accountId.equals(accountId) &
              tbl.editAt.isBiggerOrEqualValue(datetime.toIso8601String())))
        .get();
  }

  Future<void> insertStatus(EspJpnWordStatusTableData data) async {
    await into(espJpnWordStatus).insert(data);
    AppLogger.print("insert");
  }

  Future<bool> exist(int id, String accountId) async {
    final existingColum = await (select(espJpnWordStatus)
          ..where((t) => t.wordId.equals(id) & t.accountId.equals(accountId)))
        .getSingleOrNull();
    return existingColum != null ? true : false;
  }

  /// Deletes a single row for [wordId] scoped to [accountId]. Used by the
  /// guest-to-account migration to remove a guest row once its values have
  /// been merged into the target account's row.
  Future<void> deleteRow(int wordId, String accountId) async {
    await (delete(espJpnWordStatus)
          ..where(
              (t) => t.wordId.equals(wordId) & t.accountId.equals(accountId)))
        .go();
  }

  /// Persists the remote transaction acknowledgement only when no later
  /// local write has superseded the leased revision.
  Future<bool> acknowledgeRemoteMutation({
    required int wordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  }) async {
    final changed = await (update(espJpnWordStatus)
          ..where((t) =>
              t.wordId.equals(wordId) &
              t.accountId.equals(accountId) &
              t.localRevision.equals(localRevision)))
        .write(EspJpnWordStatusCompanion(
      remoteRevision: Value(remoteRevision),
      lastMutationId: Value(lastMutationId),
    ));
    return changed == 1;
  }

  /// Applies a pulled remote snapshot to the local row without bumping
  /// `local_revision` or touching the outbox, so remote apply never looks
  /// like a fresh local edit. `null` per field means "leave untouched"
  /// (used by the sync handler to skip fields with an in-flight local push).
  Future<void> applyRemoteFields(
    int wordId, {
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    required String editAt,
    required String accountId,
    String? remoteRevision,
    String? lastMutationId,
  }) {
    return transaction(() async {
      final existing = await getStatusById(wordId, accountId);
      if (existing == null) {
        await into(espJpnWordStatus).insert(
          EspJpnWordStatusCompanion.insert(
            wordId: wordId,
            isLearned: Value(isLearned == true ? 1 : 0),
            isBookmarked: Value(isBookmarked == true ? 1 : 0),
            hasNote: Value(hasNote == true ? 1 : 0),
            editAt: editAt,
            accountId: Value(accountId),
            localRevision: const Value(0),
            remoteRevision: Value(remoteRevision),
            lastMutationId: Value(lastMutationId),
          ),
        );
        return;
      }
      await (update(espJpnWordStatus)
            ..where(
                (t) => t.wordId.equals(wordId) & t.accountId.equals(accountId)))
          .write(
        EspJpnWordStatusCompanion(
          isLearned: isLearned != null
              ? Value(isLearned ? 1 : 0)
              : const Value.absent(),
          isBookmarked: isBookmarked != null
              ? Value(isBookmarked ? 1 : 0)
              : const Value.absent(),
          hasNote:
              hasNote != null ? Value(hasNote ? 1 : 0) : const Value.absent(),
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
}
