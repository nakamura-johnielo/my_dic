import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as db;

abstract class IMyWordLocalDataSource {
  Future<db.MyWordTableData?> getMyWordById(String id, String accountId);

  Future<List<db.MyWordTableData>?> getFilteredMyWordByPage(
      int size, int offset, String accountId);

  Future<List<String>?> getIdsFilteredMyWordByPage(
      int size, int offset, String accountId);

  Future<void> insertMyWord(
      String id, String headword, String description, String dateTime);

  Future<int> deleteMyword(String wordId, String editAt);

  Future<int> updateMyWord(
      String id, String word, String contents, String dateTime);

  Future<List<db.MyWordTableData>> getMyWordsAfter(String dateTime);

  Stream<List<String>> watchMyWordIdsAfter(String dateTime);
  Stream<db.MyWordTableData?> streamMyWordById(String id, String accountId);

  /// Inserts a brand-new MyWord row with `local_revision` starting at 1.
  Future<db.MyWordTableData> insertMyWordWithRevision({
    required String id,
    required String word,
    required String contents,
    required String editAt,
    required String accountId,
  });

  /// Updates an existing MyWord row and bumps `local_revision` by 1.
  /// Returns `null` if no row matched.
  Future<db.MyWordTableData?> updateMyWordWithRevision({
    required String id,
    required String word,
    required String contents,
    required String editAt,
    required String accountId,
  });

  /// Soft-deletes (tombstones) a MyWord row instead of a hard delete.
  /// Returns `null` if no non-deleted row matched.
  Future<db.MyWordTableData?> tombstoneMyWord(
      String wordId, String deletedAt, String accountId);

  /// Applies a pulled remote snapshot without bumping `local_revision` or
  /// enqueueing an outbox mutation. `null` per field means "leave untouched".
  Future<void> applyRemoteFields(
    String wordId, {
    String? word,
    String? contents,
    String? deletedAt,
    required String editAt,
    required String accountId,
    String? remoteRevision,
    String? lastMutationId,
  });

  /// Runs [action] within a single Drift transaction so callers can combine
  /// a MyWord row write with an outbox mutation atomically.
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// Stores server metadata only if the local row still has the revision
  /// leased for the remote mutation.
  Future<bool> acknowledgeRemoteMutation({
    required String wordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  });

  /// Returns every non-deleted row for [accountId]. Used by the guest-data
  /// detector/migration, which needs the full set rather than a page.
  Future<List<db.MyWordTableData>> getAllByAccountId(String accountId);

  /// Reassigns a row's account scope in place. Returns `null` if no row
  /// matched at [fromAccountId] or a row already exists at [toAccountId].
  Future<db.MyWordTableData?> reassignAccountId(
      String wordId, String fromAccountId, String toAccountId);
}
