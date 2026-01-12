import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart' as db;
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_local_data_source.dart';

class MyWordDriftDataSource implements IMyWordLocalDataSource {
  final MyWordDao _myWordDao;

  MyWordDriftDataSource(this._myWordDao);

  @override
  Future<db.MyWordTableData?> getMyWordById(int id) async {
    return await _myWordDao.getMyWordById(id);
  }

  @override
  Future<List<db.MyWordTableData>?> getFilteredMyWordByPage(int size, int offset) async {
    return await _myWordDao.getFilteredMyWordByPage(size, offset);
  }


  @override
  Future<List<int>?> getIdsFilteredMyWordByPage(int size, int offset) async {
    return await _myWordDao.getIdsFilteredMyWordByPage(size, offset);
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
  Future<List<db.MyWordTableData>> getMyWordsAfter(String dateTime) {
    return _myWordDao.getMyWordsAfter(dateTime);
  }

  @override
  Stream<List<int>> watchMyWordIdsAfter(String dateTime) {
    return _myWordDao.watchMyWordIdsAfter(dateTime);
  }
  
  @override
  Stream<db.MyWordTableData?> streamMyWordById(int id) {
    return _myWordDao.streamMyWordById(id);
  }
}
