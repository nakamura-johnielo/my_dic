import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

abstract class ILocalJpnEspWordStatusDataSource {
  Future<JpnEspWordStatusTableData?> getWordStatusById(int id);
  Future<List<JpnEspWordStatusTableData>> getWordStatusAfter(DateTime datetime);
  Future<JpnEspWordStatusTableData> updateWordStatus(
    int wordId,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    String editAt,
  );
  Stream<JpnEspWordStatusTableData?> watchWordStatusById(int id);
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
