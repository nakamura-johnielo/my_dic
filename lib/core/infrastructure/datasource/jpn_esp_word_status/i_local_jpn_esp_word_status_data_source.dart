import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

abstract class ILocalJpnEspWordStatusDataSource {
  Future<JpnEspWordStatusTableData?> getWordStatusById(
      int id, String accountId);
  Future<List<JpnEspWordStatusTableData>> getWordStatusAfter(
      DateTime datetime, String accountId);
  Future<JpnEspWordStatusTableData> updateWordStatus(
    int wordId,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    String editAt,
    String accountId,
  );
  Stream<JpnEspWordStatusTableData?> watchWordStatusById(
      int id, String accountId);
  Stream<List<int>> watchChangedIds(DateTime datetime, String accountId);

  /// Applies a pulled remote snapshot without bumping local_revision or
  /// enqueueing an outbox mutation. `null` per field means "leave untouched".
  Future<void> applyRemoteFields(
    int wordId, {
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    required String editAt,
    required String accountId,
    String? remoteRevision,
    String? lastMutationId,
  });

  /// Runs [action] within a single Drift transaction so that callers can
  /// combine a status row write with an outbox mutation atomically.
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// Stores server metadata only if [localRevision] still identifies the
  /// leased edit.
  Future<bool> acknowledgeRemoteMutation({
    required int wordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  });

  /// Deletes a single row for [id] scoped to [accountId]. Used by the
  /// guest-to-account migration to remove a guest row once merged.
  Future<void> deleteRow(int id, String accountId);
}
