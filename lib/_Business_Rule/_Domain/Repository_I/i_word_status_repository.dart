import 'package:my_dic/core/domain/entity/word/esp_word.dart';

abstract class IWordStatusRepository {
  Stream<WordStatus> watchWordStatusById(int id);
  Future<WordStatus> getWordStatusById(int id);
  Future<void> updateWordStatus(
      WordStatus wordStatus, DateTime now, String userId);
  Future<void> deleteWordStatus(WordStatus wordStatus);
}
