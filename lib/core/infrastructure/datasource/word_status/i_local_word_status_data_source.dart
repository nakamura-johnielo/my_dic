import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

abstract class ILocalWordStatusDataSource {
  Future<EspJpnWordStatusTableData?> getWordStatusById(int id);
  Future<List<EspJpnWordStatusTableData>> getWordStatusAfter(DateTime datetime);
  Future<EspJpnWordStatusTableData> updateWordStatus(
    int wordId,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    String editAt,
  );
  Stream<EspJpnWordStatusTableData?> watchWordStatusById(int id);
  Stream<List<int>> watchChangedIds(DateTime datetime);

  /// Applies a pulled remote snapshot without bumping local_revision or
  /// enqueueing an outbox mutation. `null` per field means "leave untouched".
  Future<void> applyRemoteFields(
    int wordId, {
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    required String editAt,
  });

  /// Runs [action] within a single Drift transaction so that callers can
  /// combine a status row write with an outbox mutation atomically.
  Future<T> runInTransaction<T>(Future<T> Function() action);
}
