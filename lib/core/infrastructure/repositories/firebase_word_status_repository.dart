import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/database/firebase/daos/firebase_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/dtos/wordStatusEntity.dart';

class FirebaseWordStatusRepository implements IRemoteWordStatusRepository {
  final FirebaseWordStatusDao _dao;

  FirebaseWordStatusRepository(this._dao);

  @override
  Future<WordStatus?> getWordStatusById(String userId, int id) async {
    final entity = await _dao.getWordStatus(userId, id);
    if (entity == null) {
      return WordStatus(wordId: id);
    }
    return entity.toEntity();
  }

  @override
  Future<List<WordStatus>> getWordStatusAfter(
      String userId, DateTime datetime) async {
    final entities = await _dao.getWordStatusAfter(userId, datetime);
    if (entities.isEmpty) {
      return [];
    }
    // 複数ある場合は最新のものを返す（要件に応じて調整）
    return entities.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> updateWordStatus(String userId, WordStatus wordStatus) async {
    final entity = WordStatusDTO.fromAppEntity(wordStatus);
    await _dao.update(entity, userId);
  }

  @override
  Stream<WordStatus> watchWordStatusById(String userId, int id) {
    return _dao.watchAll(userId).map((entities) {
      final entity = entities.firstWhere(
        (e) => e.wordId == id,
        orElse: () => WordStatusDTO(
          wordId: id,
          isLearned: 0,
          isBookmarked: 0,
          hasNote: 0,
          updatedAt: DateTime.now().toUtc(),
          createdAt: DateTime.now().toUtc(),
        ),
      );
      return entity.toEntity();
    });
  }

  @override
  Stream<List<int>> watchChangedIds(String userId) {
    return _dao.watchChangedWordIds(userId);
  }

  @override
  Future<void> updateWordStatusBatch(
      String userId, List<WordStatus> wordStatusList) async {
    print("~~~~~~~~~~~~~remote Batch");
    final inputData =
        wordStatusList.map((d) => WordStatusDTO.fromAppEntity(d)).toList();
    await _dao.updateBatch(userId, inputData);
  }
}
