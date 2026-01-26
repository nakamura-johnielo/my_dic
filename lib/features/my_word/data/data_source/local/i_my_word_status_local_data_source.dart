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
}
