import 'package:my_dic/features/my_word/internal/infrastructure/data/dao/local/drift_my_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as db;
import 'package:my_dic/features/my_word/internal/infrastructure/data/dataSource/my_word_status_local_store.dart';

final class DriftMyWordStatusDataSource
    implements IMyWordStatusLocalDataSource {
  final MyWordStatusDao _wordStatusDao;

  DriftMyWordStatusDataSource(this._wordStatusDao);

  @override
  Future<void> updateStatus(
    final String myWordId,
    final int? isLearned,
    final int? isBookmarked,
    final int? hasNote,
    final String editAt,
  ) =>
      _wordStatusDao.updateStatus(
          myWordId, isLearned, isBookmarked, hasNote, editAt);

  @override
  Future<void> insertStatus(db.MyWordStatusTableData data) =>
      _wordStatusDao.insertStatus(data);

  @override
  Future<bool> existStatus(String id) => _wordStatusDao.exist(id);

  @override
  Stream<db.MyWordStatusTableData?> watchWordStatus(
          String wordId, String accountId) =>
      _wordStatusDao.watchWordStatus(wordId, accountId);

  @override
  Future<db.MyWordStatusTableData?> getWordStatus(
      String wordId, String accountId) async {
    return await _wordStatusDao.getWordStatus(wordId, accountId);
  }

  @override
  Future<db.MyWordStatusTableData> applyStatusPatch(
    String myWordId,
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    String editAt,
    String accountId,
  ) {
    return _wordStatusDao.applyStatusPatch(
        myWordId, isLearned, isBookmarked, hasNote, editAt, accountId);
  }

  @override
  Future<void> applyRemoteFields(
    String myWordId, {
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    required String editAt,
    required String accountId,
    String? remoteRevision,
    String? lastMutationId,
  }) {
    return _wordStatusDao.applyRemoteFields(
      myWordId,
      isLearned: isLearned,
      isBookmarked: isBookmarked,
      hasNote: hasNote,
      editAt: editAt,
      accountId: accountId,
      remoteRevision: remoteRevision,
      lastMutationId: lastMutationId,
    );
  }

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      _wordStatusDao.transaction(action);

  @override
  Future<bool> acknowledgeRemoteMutation({
    required String myWordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  }) =>
      _wordStatusDao.acknowledgeRemoteMutation(
        myWordId: myWordId,
        accountId: accountId,
        localRevision: localRevision,
        remoteRevision: remoteRevision,
        lastMutationId: lastMutationId,
      );

  @override
  Future<List<db.MyWordStatusTableData>> getAllByAccountId(String accountId) =>
      _wordStatusDao.getAllByAccountId(accountId);

  @override
  Future<db.MyWordStatusTableData?> reassignAccountId(
          String myWordId, String fromAccountId, String toAccountId) =>
      _wordStatusDao.reassignAccountId(myWordId, fromAccountId, toAccountId);

  @override
  Future<void> deleteRow(String myWordId, String accountId) =>
      _wordStatusDao.deleteRow(myWordId, accountId);
}
