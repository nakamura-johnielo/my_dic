import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_repository_input_data.dart';

abstract class IJpnEspWordStatusRepository {
  Stream<JpnEspWordStatus> watchWordStatusById(int id);
  Future<Result<JpnEspWordStatus?>> getWordStatusById(int id);
  Future<Result<void>> deleteWordStatus(JpnEspWordStatus wordStatus);

  //remote
  Stream<List<int>> watchRemoteChangedIds(String userId);
  Future<Result<void>> updateRemoteWordStatus(
    JpnEspWordStatus wordStatus,
    String userId,
    DateTime? now,
  );
  Future<Result<void>> updateBatchRemoteWordStatus(
    List<JpnEspWordStatus> wordStatusList,
    String userId,
    DateTime? now,
  );
  Future<Result<List<JpnEspWordStatus>>> getRemoteWordStatusAfter(
      String userId, DateTime datetime);
  Future<Result<JpnEspWordStatus?>> getRemoteWordStatusById(
      String userId, int id);

  //local
  Stream<List<int>> watchLocalChangedIds(DateTime datetime);
  Future<Result<JpnEspWordStatus>> updateLocalWordStatus(
    UpdateJpnEspStatusRepositoryInputData input,
    DateTime editAt,
  );
  Future<Result<List<JpnEspWordStatus>>> getLocalWordStatusAfter(
      DateTime datetime);
  Future<Result<JpnEspWordStatus?>> getLocalWordStatusById(int id);
}
