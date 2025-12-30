import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';

abstract class IRemoteWordStatusDataSource {
  Future<WordStatus?> getWordStatusById(String userId, int id);
  Future<List<WordStatus>> getWordStatusAfter(String userId, DateTime datetime);
  Future<void> updateWordStatus(String userId, WordStatus wordStatus);
  Stream<WordStatus> watchWordStatusById(String userId, int id);
  Stream<List<int>> watchChangedIds(String userId);
  Future<void> updateWordStatusBatch(String userId, List<WordStatus> list);
}
