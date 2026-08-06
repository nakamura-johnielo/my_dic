import 'package:my_dic/features/jpn_esp_word_status/data/jpn_esp_word_status_entity.dart';

abstract class IRemoteJpnEspWordStatusDataSource {
  Future<JpnEspWordStatusDTO?> getWordStatusById(String userId, int id);
  Future<List<JpnEspWordStatusDTO>> getWordStatusAfter(
      String userId, DateTime datetime);
  Future<void> updateWordStatus(String userId, JpnEspWordStatusDTO wordStatus);
  Stream<JpnEspWordStatusDTO> watchWordStatusById(String userId, int id);
  Stream<List<int>> watchChangedIds(String userId);
  Future<void> updateWordStatusBatch(String userId, List<JpnEspWordStatusDTO> list);

  /// Writes only the fields named in [fieldMask], leaving every other remote
  /// field untouched. [isNew] controls whether `createdAt` is also stamped.
  Future<void> patchWordStatus(
    String userId,
    int wordId,
    Map<String, Object?> fields,
    List<String> fieldMask, {
    required bool isNew,
  });
}
