import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';

abstract class IWordStatusRepository {
  // Future<Result<void>> updateWordStatus(
  //     WordStatus wordStatus, DateTime now, String userId,);
  //
  Stream<WordStatus> watchWordStatusById(int id);
  Future<Result<WordStatus?>> getWordStatusById(int id);
  Future<Result<void>> deleteWordStatus(WordStatus wordStatus); //TODO 未使用

  //remote
  Stream<List<int>> watchRemoteChangedIds(String userId);
  Future<Result<void>> updateRemoteWordStatus(
    WordStatus wordStatus,
    String userId,
    DateTime? now,
  );
  Future<Result<void>> updateBatchRemoteWordStatus(
    List<WordStatus> wordStatusList,
    String userId,
    DateTime? now,
  );
  Future<Result<List<WordStatus>>> getRemoteWordStatusAfter(
      String userId, DateTime datetime);
  Future<Result<WordStatus?>> getRemoteWordStatusById(String userId, int id);

  //local
  Stream<List<int>> watchLocalChangedIds(DateTime datetime); //TODO 未使用
  Future<Result<void>> updateLocalWordStatus(
    int wordId,
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    DateTime editAt,
  );
  Future<Result<List<WordStatus>>> getLocalWordStatusAfter(DateTime datetime);
  Future<Result<WordStatus?>> getLocalWordStatusById(int id);
}

// abstract class ILocalWordStatusRepository {
//
//   Future<WordStatus> getWordStatusById(int id);
//   Future<List<WordStatus>> getWordStatusAfter(DateTime datetime);
//   Future<void> updateWordStatus(WordStatus wordStatus);

//   Stream<WordStatus> watchWordStatusById(int id); //TODO 未使用
//   Stream<List<int>> watchChangedIds(DateTime datetime);
// }

// abstract class IRemoteWordStatusRepository {
//   Future<void> updateWordStatusBatch(String userId, List<WordStatus> wordStatusList);
//   Future<WordStatus?> getWordStatusById(String userId, int id);
//   Future<List<WordStatus>> getWordStatusAfter(String userId, DateTime datetime);
//   Future<void> updateWordStatus(String userId, WordStatus wordStatus);

//   Stream<WordStatus> watchWordStatusById(String userId, int id);//TODO 未使用
//   Stream<List<int>> watchChangedIds(String userId);
// }
