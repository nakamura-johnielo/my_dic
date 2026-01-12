import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/update_my_word_status_repository_input_data.dart';

abstract class IMyWordStatusRepository {
  // Local methods
  Future<Result<void>> updateStatus(UpdateMyWordStatusRepositoryInputData input);
  Stream<MyWordStatus> watchStatus(int wordId);

  // Remote sync methods
  Future<Result<List<MyWordStatus>>> getRemoteStatusAfter(
      String userId, DateTime datetime);
  Future<Result<MyWordStatus?>> getRemoteStatusById(
      String userId, int myWordId);
  Future<Result<void>> updateRemoteStatus(
      String userId, MyWordStatus status, DateTime? now);
  Future<Result<void>> updateBatchRemoteStatus(
      String userId, List<MyWordStatus> statusList);

  Future<Result<List<MyWordStatus>>> getLocalStatusAfter(DateTime datetime);
  Future<Result<MyWordStatus?>> getLocalStatusById(int myWordId);
  Future<Result<void>> updateLocalStatus(MyWordStatus status, DateTime now);

  Stream<List<int>> watchRemoteChangedIds(String userId);
  Stream<List<int>> watchLocalChangedIds(DateTime datetime);
}
