import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

import 'i_local_word_status_data_source.dart';

class DriftWordStatusDataSource implements ILocalWordStatusDataSource {
  final EspJpnWordStatusDao _dao;
  DriftWordStatusDataSource(this._dao);

  @override
  Future<EspJpnWordStatusTableData?> getWordStatusById(int id) async {
    final data = await _dao.getStatusById(id);
    return data;
  }

  @override
  Future<List<EspJpnWordStatusTableData>> getWordStatusAfter(
      DateTime datetime) async {
    final list = await _dao.getWordStatusAfter(datetime);
    return list;
  }

  @override
  Future<EspJpnWordStatusTableData> updateWordStatus(
    int wordId,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    String editAt,
  ) async {
    return _dao.applyStatusPatch(
      wordId,
      isLearned,
      isBookmarked,
      hasNote,
      editAt,
    );
  }

  @override
  Stream<EspJpnWordStatusTableData?> watchWordStatusById(int id) {
    return _dao.watchWordStatus(id);
  }

  @override
  Stream<List<int>> watchChangedIds(DateTime datetime) {
    return _dao.watchChangedWordIdsWithFilter(datetime);
  }

  @override
  Future<void> applyRemoteFields(
    int wordId, {
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    required String editAt,
  }) {
    return _dao.applyRemoteFields(
      wordId,
      isLearned: isLearned,
      isBookmarked: isBookmarked,
      hasNote: hasNote,
      editAt: editAt,
    );
  }

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      _dao.transaction(action);
}
