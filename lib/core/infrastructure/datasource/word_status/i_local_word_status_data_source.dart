import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';

abstract class ILocalWordStatusDataSource {
  Future<WordStatus> getWordStatusById(int id);
  Future<List<WordStatus>> getWordStatusAfter(DateTime datetime);
  Future<void> updateWordStatus(WordStatus wordStatus);
  Stream<WordStatus> watchWordStatusById(int id);
  Stream<List<int>> watchChangedIds(DateTime datetime);
}
