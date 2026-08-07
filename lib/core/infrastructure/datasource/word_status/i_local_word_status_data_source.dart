import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

abstract class ILocalWordStatusDataSource {
  Future<EspJpnWordStatusTableData?> getWordStatusById(
      int id, String accountId);
  Future<List<EspJpnWordStatusTableData>> getWordStatusAfter(
      DateTime datetime, String accountId);
  Future<EspJpnWordStatusTableData> updateWordStatus(
    int wordId,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    String editAt,
    String accountId,
  );
  Stream<EspJpnWordStatusTableData?> watchWordStatusById(
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
  });

  /// Runs [action] within a single Drift transaction so that callers can
  /// combine a status row write with an outbox mutation atomically.
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// Deletes a single row for [id] scoped to [accountId]. Used by the
  /// guest-to-account migration to remove a guest row once merged.
  Future<void> deleteRow(int id, String accountId);
}
