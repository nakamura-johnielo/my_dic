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

  /// Runs [action] within a single Drift transaction so that callers can
  /// combine a status row write with an outbox mutation atomically.
  Future<T> runInTransaction<T>(Future<T> Function() action);
}
