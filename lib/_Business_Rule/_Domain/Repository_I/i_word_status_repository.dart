import 'package:my_dic/_Business_Rule/_Domain/Entities/word/word_status.dart';

abstract class IWordStatusRepository {
  Stream<WordStatus> watchWordStatusById(int id);
  Future<WordStatus> getWordStatusById(int id);
  Future<void> updateWordStatus(WordStatus wordStatus);
  Future<void> deleteWordStatus(WordStatus wordStatus);
}
