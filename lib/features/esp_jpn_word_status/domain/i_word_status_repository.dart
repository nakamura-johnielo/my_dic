import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_repository_input_data.dart';

abstract class IWordStatusRepository {
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
  Future<Result<WordStatus>> updateLocalWordStatus(
    UpdateStatusRepositoryInputData input,
    DateTime editAt,
  );
  Future<Result<List<WordStatus>>> getLocalWordStatusAfter(DateTime datetime);
  Future<Result<WordStatus?>> getLocalWordStatusById(int id);
}
