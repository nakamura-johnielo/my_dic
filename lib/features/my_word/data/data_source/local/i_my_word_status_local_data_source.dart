import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart' as db;

abstract class IMyWordStatusLocalDataSource {
  Future<void> updateStatus(
  final int myWordId,
  final int? isLearned,
  final int? isBookmarked,
  final int? hasNote,
  final String editAt,);
  Future<void> insertStatus(db.MyWordStatusTableData data);
  Future<bool> existStatus(int id);
  Stream<db.MyWordStatusTableData?> watchWordStatus(int wordId);
  Future<db.MyWordStatusTableData?> getWordStatus(int wordId);
}
