import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart' as db;

abstract class IMyWordStatusLocalDataSource {
  Future<void> updateStatus(
  final String myWordId,
  final int? isLearned,
  final int? isBookmarked,
  final int? hasNote,
  final String editAt,);
  Future<void> insertStatus(db.MyWordStatusTableData data);
  Future<bool> existStatus(String id);
  Stream<db.MyWordStatusTableData?> watchWordStatus(String wordId);
  Future<db.MyWordStatusTableData?> getWordStatus(String wordId);

  /// Upserts the status row and bumps `local_revision` by 1.
  Future<db.MyWordStatusTableData> applyStatusPatch(
    String myWordId,
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    String editAt,
  );

  /// Applies a pulled remote snapshot without bumping `local_revision` or
  /// enqueueing an outbox mutation. `null` per field means "leave untouched".
  Future<void> applyRemoteFields(
    String myWordId, {
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    required String editAt,
  });

  /// Runs [action] within a single Drift transaction so callers can combine
  /// a status row write with an outbox mutation atomically.
  Future<T> runInTransaction<T>(Future<T> Function() action);
}
