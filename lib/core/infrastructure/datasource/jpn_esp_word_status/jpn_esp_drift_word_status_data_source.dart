import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

import 'i_local_jpn_esp_word_status_data_source.dart';

class JpnEspDriftWordStatusDataSource implements ILocalJpnEspWordStatusDataSource {
  final JpnEspWordStatusDao _dao;
  JpnEspDriftWordStatusDataSource(this._dao);

  @override
  Future<JpnEspWordStatusTableData?> getWordStatusById(int id) async {
    final data = await _dao.getStatusById(id);
    return data;
  }

  @override
  Future<List<JpnEspWordStatusTableData>> getWordStatusAfter(
      DateTime datetime) async {
    final list = await _dao.getWordStatusAfter(datetime);
    return list;
  }

  @override
  Future<void> updateWordStatus(
    int wordId,
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    String editAt,
  ) async {
    if (await _dao.exist(wordId)) {
      await _dao.updateStatus(
        wordId,
        isLearned,
        isBookmarked,
        hasNote,
        editAt,
      );
    } else {
      await _dao.insertStatus(JpnEspWordStatusTableData(
          wordId: wordId,
          isLearned: isLearned ?? 0,
          isBookmarked: isBookmarked ?? 0,
          hasNote: hasNote ?? 0,
          editAt: editAt));
    }
  }

  @override
  Stream<JpnEspWordStatusTableData?> watchWordStatusById(int id) {
    return _dao.watchWordStatus(id);
  }

  @override
  Stream<List<int>> watchChangedIds(DateTime datetime) {
    return _dao.watchChangedWordIdsWithFilter(datetime);
  }
}
