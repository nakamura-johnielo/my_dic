import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';

abstract class IWordStatusRepository {
  Future<void> updateWordStatus(
      WordStatus wordStatus, DateTime now, String userId,
      {bool isFromSync = false});
  Stream<WordStatus> watchWordStatusById(int id);
  Future<WordStatus> getWordStatusById(int id);
  Future<void> deleteWordStatus(WordStatus wordStatus);
}

abstract class ILocalWordStatusRepository {
  Future<WordStatus> getWordStatusById(int id);
  Future<List<WordStatus>> getWordStatusAfter(DateTime datetime);
  Future<void> updateWordStatus(WordStatus wordStatus);

  Stream<WordStatus> watchWordStatusById(int id);
  Stream<List<int>> watchChangedIds(DateTime datetime);
}

abstract class IRemoteWordStatusRepository {
  Future<WordStatus?> getWordStatusById(String userId, int id);
  Future<List<WordStatus>> getWordStatusAfter(String userId, DateTime datetime);
  Future<void> updateWordStatus(String userId, WordStatus wordStatus);

  Stream<WordStatus> watchWordStatusById(String userId, int id);
  Stream<List<int>> watchChangedIds(String userId);
}
