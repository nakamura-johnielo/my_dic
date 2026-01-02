import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart' as db;
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_local_data_source.dart';

class MyWordDriftDataSource implements IMyWordLocalDataSource {
  final MyWordDao _myWordDao;
  final MyWordStatusDao _wordStatusDao;

  MyWordDriftDataSource(this._myWordDao, this._wordStatusDao);

  @override
  Future<db.MyWordTableData?> getMyWordById(int id) async {
    return await _myWordDao.getMyWordById(id);
  }

  @override
  Future<List<db.MyWordTableData>?> getFilteredMyWordByPage(int size, int offset) async {
    return await _myWordDao.getFilteredMyWordByPage(size, offset);
  }

  @override
  Future<int> insertMyWord(String headword, String description, String dateTime) =>
      _myWordDao.insertMyWord(headword, description, dateTime);

  @override
  Future<int> deleteMyword(int wordId, String editAt) => _myWordDao.deleteMyword(wordId, editAt);

  @override
  Future<int> updateMyWord(int id, String word, String contents, String dateTime) =>
      _myWordDao.updateMyWord(id, word, contents, dateTime);

  @override
  Future<void> updateStatus(db.MyWordStatusTableData data) => _wordStatusDao.updateStatus(data);

  @override
  Future<void> insertStatus(db.MyWordStatusTableData data) => _wordStatusDao.insertStatus(data);

  @override
  Future<bool> existStatus(int id) => _wordStatusDao.exist(id);
}
