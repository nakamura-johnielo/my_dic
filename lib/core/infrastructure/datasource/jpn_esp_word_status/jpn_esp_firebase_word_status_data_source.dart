import 'package:my_dic/core/infrastructure/database/firebase/daos/jpn_esp/firebase_jpn_esp_word_status_dao.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/jpn_esp_word_status_entity.dart';

import 'i_remote_jpn_esp_word_status_data_source.dart';

class JpnEspFirebaseWordStatusDataSource implements IRemoteJpnEspWordStatusDataSource {
  final FirebaseJpnEspWordStatusDao _dao;
  JpnEspFirebaseWordStatusDataSource(this._dao);

  @override
  Future<JpnEspWordStatusDTO?> getWordStatusById(String userId, int id) async {
    final dto = await _dao.getWordStatus(userId, id);
    return dto;
  }

  @override
  Future<List<JpnEspWordStatusDTO>> getWordStatusAfter(
      String userId, DateTime datetime) async {
    final list = await _dao.getWordStatusAfter(userId, datetime);
    return list;
  }

  @override
  Future<void> updateWordStatus(String userId, JpnEspWordStatusDTO wordStatus) async {
    await _dao.update(wordStatus, userId);
  }

  @override
  Stream<JpnEspWordStatusDTO> watchWordStatusById(String userId, int id) {
    return _dao.watchAll(userId).map((entities) {
      final e = entities.firstWhere((e) => e.wordId == id,
          orElse: () => JpnEspWordStatusDTO(
              wordId: id,
              isLearned: 0,
              isBookmarked: 0,
              hasNote: 0,
              updatedAt: DateTime.now().toUtc(),
              createdAt: DateTime.now().toUtc()));
      return e;
    });
  }

  @override
  Stream<List<int>> watchChangedIds(String userId) =>
      _dao.watchChangedWordIds(userId);

  @override
  Future<void> updateWordStatusBatch(
      String userId, List<JpnEspWordStatusDTO> wordStatusList) async {
    await _dao.updateBatch(userId, wordStatusList);
  }
}
