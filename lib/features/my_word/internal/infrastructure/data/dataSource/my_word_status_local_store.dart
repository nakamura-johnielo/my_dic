import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as db;

abstract interface class IMyWordStatusLocalDataSource {
  Future<void> updateStatus(
    final String myWordId,
    final int? isLearned,
    final int? isBookmarked,
    final int? hasNote,
    final String editAt,
  );
  Future<void> insertStatus(db.MyWordStatusTableData data);
  Future<bool> existStatus(String id);
  Stream<db.MyWordStatusTableData?> watchWordStatus(
      String wordId, String accountId);
  Future<db.MyWordStatusTableData?> getWordStatus(
      String wordId, String accountId);

  /// Upserts the status row and bumps `local_revision` by 1.
  Future<db.MyWordStatusTableData> applyStatusPatch(
    String myWordId,
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    String editAt,
    String accountId,
  );

  /// Applies a pulled remote snapshot without bumping `local_revision` or
  /// enqueueing an outbox mutation. `null` per field means "leave untouched".
  Future<void> applyRemoteFields(
    String myWordId, {
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    required String editAt,
    required String accountId,
    String? remoteRevision,
    String? lastMutationId,
  });

  /// Runs [action] within a single Drift transaction so callers can combine
  /// a status row write with an outbox mutation atomically.
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// Stores server metadata only if the local row still has the revision
  /// leased for the remote mutation.
  Future<bool> acknowledgeRemoteMutation({
    required String myWordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  });

  /// Returns every row for [accountId]. Used by the guest-data
  /// detector/migration, which needs the full set rather than a single row.
  Future<List<db.MyWordStatusTableData>> getAllByAccountId(String accountId);

  /// Reassigns a status row's account scope in place. Returns `null` if no
  /// row matched at [fromAccountId] or a row already exists at [toAccountId].
  Future<db.MyWordStatusTableData?> reassignAccountId(
      String myWordId, String fromAccountId, String toAccountId);

  /// Deletes one status row in the requested account scope after it has been
  /// merged into another scope during guest-data migration.
  Future<void> deleteRow(String myWordId, String accountId);
}
