import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

import 'i_local_jpn_esp_word_status_data_source.dart';

class JpnEspDriftWordStatusDataSource
    implements ILocalJpnEspWordStatusDataSource {
  final JpnEspWordStatusDao _dao;
  JpnEspDriftWordStatusDataSource(this._dao);

  @override
  Future<JpnEspWordStatusTableData?> getWordStatusById(
      int id, String accountId) async {
    final data = await _dao.getStatusById(id, accountId);
    return data;
  }

  @override
  Future<List<JpnEspWordStatusTableData>> getWordStatusAfter(
      DateTime datetime, String accountId) async {
    final list = await _dao.getWordStatusAfter(datetime, accountId);
    return list;
  }

  @override
  Future<JpnEspWordStatusTableData> updateWordStatus(
    int wordId,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    String editAt,
    String accountId,
  ) async {
    return _dao.applyStatusPatch(
      wordId,
      isLearned,
      isBookmarked,
      hasNote,
      editAt,
      accountId,
    );
  }

  @override
  Stream<JpnEspWordStatusTableData?> watchWordStatusById(
      int id, String accountId) {
    return _dao.watchWordStatus(id, accountId);
  }

  @override
  Stream<List<int>> watchChangedIds(DateTime datetime, String accountId) {
    return _dao.watchChangedWordIdsWithFilter(datetime, accountId);
  }

  @override
  Future<void> applyRemoteFields(
    int wordId, {
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    required String editAt,
    required String accountId,
  }) {
    return _dao.applyRemoteFields(
      wordId,
      isLearned: isLearned,
      isBookmarked: isBookmarked,
      hasNote: hasNote,
      editAt: editAt,
      accountId: accountId,
    );
  }

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      _dao.transaction(action);

  @override
  Future<void> deleteRow(int id, String accountId) =>
      _dao.deleteRow(id, accountId);
}
