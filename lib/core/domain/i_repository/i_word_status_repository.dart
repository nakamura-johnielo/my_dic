import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';

abstract class IWordStatusRepository {
  Future<Result<void>> updateWordStatus(
      WordStatus wordStatus, DateTime now, String userId,);
      //
  Future<Result<void>> updateLocalWordStatus(
      WordStatus wordStatus, DateTime now, String userId,);
  Future<Result<void>> updateRemoteWordStatus(
      WordStatus wordStatus, DateTime now, String userId,);
  Stream<WordStatus> watchWordStatusById(int id);
  Future<Result<WordStatus?>> getWordStatusById(int id);
  Future<Result<void>> deleteWordStatus(WordStatus wordStatus);//TODO 未使用
}

abstract class ILocalWordStatusRepository {
  //TODO result
  Future<WordStatus> getWordStatusById(int id);
  Future<List<WordStatus>> getWordStatusAfter(DateTime datetime);
  Future<void> updateWordStatus(WordStatus wordStatus);

  Stream<WordStatus> watchWordStatusById(int id); //TODO 未使用
  Stream<List<int>> watchChangedIds(DateTime datetime);
}

abstract class IRemoteWordStatusRepository {
  Future<void> updateWordStatusBatch(String userId, List<WordStatus> wordStatusList);
  Future<WordStatus?> getWordStatusById(String userId, int id);
  Future<List<WordStatus>> getWordStatusAfter(String userId, DateTime datetime);
  Future<void> updateWordStatus(String userId, WordStatus wordStatus);

  Stream<WordStatus> watchWordStatusById(String userId, int id);//TODO 未使用
  Stream<List<int>> watchChangedIds(String userId);
}
