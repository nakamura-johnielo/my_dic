import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as db;
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/i_my_word_local_data_source.dart';

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
    String? remoteRevision,
    String? lastMutationId,
  }) {
    return _myWordDao.applyRemoteFields(
      wordId,
      word: word,
      contents: contents,
      deletedAt: deletedAt,
      editAt: editAt,
      accountId: accountId,
      remoteRevision: remoteRevision,
      lastMutationId: lastMutationId,
    );
  }

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      _myWordDao.transaction(action);

  @override
  Future<bool> acknowledgeRemoteMutation({
    required String wordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  }) =>
      _myWordDao.acknowledgeRemoteMutation(
        wordId: wordId,
        accountId: accountId,
        localRevision: localRevision,
        remoteRevision: remoteRevision,
        lastMutationId: lastMutationId,
      );

  @override
  Future<List<db.MyWordTableData>> getAllByAccountId(String accountId) =>
      _myWordDao.getAllByAccountId(accountId);

  @override
  Future<db.MyWordTableData?> reassignAccountId(
          String wordId, String fromAccountId, String toAccountId) =>
      _myWordDao.reassignAccountId(wordId, fromAccountId, toAccountId);
}
