import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart' as db;

abstract class IMyWordStatusLocalDataSource {
  Future<void> updateStatus(db.MyWordStatusTableData data);
  Future<void> insertStatus(db.MyWordStatusTableData data);
  Future<bool> existStatus(int id);
  Stream<db.MyWordStatusTableData?> watchWordStatus(int wordId);
}
