import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_repository_input_data.dart';

abstract class IWordStatusRepository {
  Stream<WordStatus> watchWordStatusById(int id, {required String accountId});
  Future<Result<WordStatus?>> getWordStatusById(int id,
      {required String accountId});
  Future<Result<void>> deleteWordStatus(WordStatus wordStatus); //TODO 未使用

  //local
  Stream<List<int>> watchLocalChangedIds(DateTime datetime,
      {required String accountId}); //TODO 未使用
  Future<Result<WordStatus>> updateLocalWordStatus(
    UpdateStatusRepositoryInputData input,
    DateTime editAt, {
    required String? accountId,
  });
  Future<Result<List<WordStatus>>> getLocalWordStatusAfter(DateTime datetime,
      {required String accountId});
  Future<Result<WordStatus?>> getLocalWordStatusById(int id,
      {required String accountId});
}
