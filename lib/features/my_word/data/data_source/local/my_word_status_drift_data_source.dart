import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart' as db;
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_status_local_data_source.dart';

class MyWordStatusDriftDataSource implements IMyWordStatusLocalDataSource {
  final MyWordStatusDao _wordStatusDao;

  MyWordStatusDriftDataSource(this._wordStatusDao);

  @override
  Future<void> updateStatus(
  final String myWordId,
  final int? isLearned,
  final int? isBookmarked,
  final int? hasNote,
  final String editAt,) => _wordStatusDao.updateStatus(myWordId, isLearned, isBookmarked, hasNote, editAt);

  @override
  Future<void> insertStatus(db.MyWordStatusTableData data) => _wordStatusDao.insertStatus(data);

  @override
  Future<bool> existStatus(String id) => _wordStatusDao.exist(id);

  @override
  Stream<db.MyWordStatusTableData?> watchWordStatus(String wordId) =>
      _wordStatusDao.watchWordStatus(wordId);
  
  @override
  Future<db.MyWordStatusTableData?> getWordStatus(String wordId) async {
    return await _wordStatusDao.getWordStatus(wordId);
  }
}
