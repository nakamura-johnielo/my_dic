import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';

abstract class IJpnEspWordStatusRepository {
  Stream<JpnEspWordStatus> watchWordStatusById(int id,
      {required String accountId});
  Future<Result<JpnEspWordStatus?>> getWordStatusById(int id,
      {required String accountId});
  Future<Result<void>> deleteWordStatus(JpnEspWordStatus wordStatus);

  //local
  Stream<List<int>> watchLocalChangedIds(DateTime datetime,
      {required String accountId});
  Future<Result<JpnEspWordStatus>> updateLocalWordStatus(
    {required int wordId,
    required FieldUpdate<bool> isLearned,
    required FieldUpdate<bool> isBookmarked,
    required FieldUpdate<bool> hasNote,
    required DateTime editAt,
    required String? accountId,
  });
  Future<Result<List<JpnEspWordStatus>>> getLocalWordStatusAfter(
      DateTime datetime,
      {required String accountId});
  Future<Result<JpnEspWordStatus?>> getLocalWordStatusById(int id,
      {required String accountId});
}
