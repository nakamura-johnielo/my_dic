import 'package:my_dic/core/infrastructure/database/firebase/daos/firebase_word_status_dao.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/infrastructure/dtos/wordStatusEntity.dart';

import 'i_remote_word_status_data_source.dart';

class FirebaseWordStatusDataSource implements IRemoteWordStatusDataSource {
  final FirebaseWordStatusDao _dao;
  FirebaseWordStatusDataSource(this._dao);

  @override
  Future<WordStatus?> getWordStatusById(String userId, int id) async {
    final dto = await _dao.getWordStatus(userId, id);
    if (dto == null) return null;
    return dto.toEntity();
  }

  @override
  Future<List<WordStatus>> getWordStatusAfter(String userId, DateTime datetime) async {
    final list = await _dao.getWordStatusAfter(userId, datetime);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> updateWordStatus(String userId, WordStatus wordStatus) async {
    final dto = WordStatusDTO.fromAppEntity(wordStatus);
    await _dao.update(dto, userId);
  }

  @override
  Stream<WordStatus> watchWordStatusById(String userId, int id) {
    return _dao.watchAll(userId).map((entities) {
      final e = entities.firstWhere((e) => e.wordId == id,
          orElse: () => WordStatusDTO(
              wordId: id, isLearned: 0, isBookmarked: 0, hasNote: 0, updatedAt: DateTime.now().toUtc(), createdAt: DateTime.now().toUtc()));
      return e.toEntity();
    });
  }

  @override
  Stream<List<int>> watchChangedIds(String userId) => _dao.watchChangedWordIds(userId);

  @override
  Future<void> updateWordStatusBatch(String userId, List<WordStatus> wordStatusList) async {
    final input = wordStatusList.map((w) => WordStatusDTO.fromAppEntity(w)).toList();
    await _dao.updateBatch(userId, input);
  }
}
