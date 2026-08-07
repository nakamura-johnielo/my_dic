import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as db;
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_local_data_source.dart';

class MyWordDriftDataSource implements IMyWordLocalDataSource {
  final MyWordDao _myWordDao;

  MyWordDriftDataSource(this._myWordDao);

  @override
  Future<db.MyWordTableData?> getMyWordById(String id, String accountId) async {
    return await _myWordDao.getMyWordById(id, accountId);
  }

  @override
  Future<List<db.MyWordTableData>?> getFilteredMyWordByPage(
      int size, int offset, String accountId) async {
    return await _myWordDao.getFilteredMyWordByPage(size, offset, accountId);
  }

  @override
  Future<List<String>?> getIdsFilteredMyWordByPage(
      int size, int offset, String accountId) async {
    return await _myWordDao.getIdsFilteredMyWordByPage(size, offset, accountId);
  }

  @override
  Future<void> insertMyWord(
          String id, String headword, String description, String dateTime) =>
      _myWordDao.insertMyWord(id, headword, description, dateTime);

  @override
  Future<int> deleteMyword(String wordId, String editAt) =>
      _myWordDao.deleteMyword(wordId, editAt);

  @override
  Future<int> updateMyWord(
          String id, String word, String contents, String dateTime) =>
      _myWordDao.updateMyWord(id, word, contents, dateTime);

  @override
  Future<List<db.MyWordTableData>> getMyWordsAfter(String dateTime) {
    return _myWordDao.getMyWordsAfter(dateTime);
  }

  @override
  Stream<List<String>> watchMyWordIdsAfter(String dateTime) {
    return _myWordDao.watchMyWordIdsAfter(dateTime);
  }

  @override
  Stream<db.MyWordTableData?> streamMyWordById(String id, String accountId) {
    return _myWordDao.streamMyWordById(id, accountId);
  }

  @override
  Future<db.MyWordTableData> insertMyWordWithRevision({
    required String id,
    required String word,
    required String contents,
    required String editAt,
    required String accountId,
  }) {
    return _myWordDao.insertMyWordWithRevision(
      id: id,
      word: word,
      contents: contents,
      editAt: editAt,
      accountId: accountId,
    );
  }

  @override
  Future<db.MyWordTableData?> updateMyWordWithRevision({
    required String id,
    required String word,
    required String contents,
    required String editAt,
    required String accountId,
  }) {
    return _myWordDao.updateMyWordWithRevision(
      id: id,
      word: word,
      contents: contents,
      editAt: editAt,
      accountId: accountId,
    );
  }

  @override
  Future<db.MyWordTableData?> tombstoneMyWord(
      String wordId, String deletedAt, String accountId) {
    return _myWordDao.tombstoneMyWord(wordId, deletedAt, accountId);
  }

  @override
  Future<void> applyRemoteFields(
    String wordId, {
    String? word,
    String? contents,
    String? deletedAt,
    required String editAt,
    required String accountId,
  }) {
    return _myWordDao.applyRemoteFields(
      wordId,
      word: word,
      contents: contents,
      deletedAt: deletedAt,
      editAt: editAt,
      accountId: accountId,
    );
  }

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      _myWordDao.transaction(action);

  @override
  Future<List<db.MyWordTableData>> getAllByAccountId(String accountId) =>
      _myWordDao.getAllByAccountId(accountId);

  @override
  Future<db.MyWordTableData?> reassignAccountId(
          String wordId, String fromAccountId, String toAccountId) =>
      _myWordDao.reassignAccountId(wordId, fromAccountId, toAccountId);
}
