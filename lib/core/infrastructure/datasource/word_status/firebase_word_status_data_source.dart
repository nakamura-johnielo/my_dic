import 'package:my_dic/core/infrastructure/database/firebase/daos/firebase_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/dtos/wordStatusEntity.dart';

import 'i_remote_word_status_data_source.dart';

class FirebaseWordStatusDataSource implements IRemoteWordStatusDataSource {
  final FirebaseWordStatusDao _dao;
  FirebaseWordStatusDataSource(this._dao);

  @override
  Future<WordStatusDTO?> getWordStatusById(String userId, int id) async {
    final dto = await _dao.getWordStatus(userId, id);
    return dto;
  }

  @override
  Future<List<WordStatusDTO>> getWordStatusAfter(String userId, DateTime datetime) async {
    final list = await _dao.getWordStatusAfter(userId, datetime);
    return list;
  }

  @override
  Future<void> updateWordStatus(String userId, WordStatusDTO wordStatus) async {
    await _dao.update(wordStatus, userId);
  }

  @override
  Stream<WordStatusDTO> watchWordStatusById(String userId, int id) {
    return _dao.watchAll(userId).map((entities) {
      final e = entities.firstWhere((e) => e.wordId == id,
          orElse: () => WordStatusDTO(
              wordId: id, isLearned: 0, isBookmarked: 0, hasNote: 0, updatedAt: DateTime.now().toUtc(), createdAt: DateTime.now().toUtc()));
      return e;
    });
  }

  @override
  Stream<List<int>> watchChangedIds(String userId) => _dao.watchChangedWordIds(userId);

  @override
  Future<void> updateWordStatusBatch(String userId, List<WordStatusDTO> wordStatusList) async {
    await _dao.updateBatch(userId, wordStatusList);
  }
}
