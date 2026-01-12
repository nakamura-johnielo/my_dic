import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart' as db;
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_status_local_data_source.dart';

class MyWordStatusDriftDataSource implements IMyWordStatusLocalDataSource {
  final MyWordStatusDao _wordStatusDao;

  MyWordStatusDriftDataSource(this._wordStatusDao);

  @override
  Future<void> updateStatus(db.MyWordStatusTableData data) => _wordStatusDao.updateStatus(data);

  @override
  Future<void> insertStatus(db.MyWordStatusTableData data) => _wordStatusDao.insertStatus(data);

  @override
  Future<bool> existStatus(int id) => _wordStatusDao.exist(id);

  @override
  Stream<db.MyWordStatusTableData?> watchWordStatus(int wordId) => _wordStatusDao.watchWordStatus(wordId);
}
