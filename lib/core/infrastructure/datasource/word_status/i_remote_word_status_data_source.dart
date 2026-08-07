import 'package:my_dic/features/esp_jpn_word_status/data/word_status_entity.dart';

abstract class IRemoteWordStatusDataSource {
  Future<WordStatusDTO?> getWordStatusById(String userId, int id);
  Future<List<WordStatusDTO>> getWordStatusAfter(
      String userId, DateTime datetime);
  Future<void> updateWordStatus(String userId, WordStatusDTO wordStatus);
  Stream<WordStatusDTO> watchWordStatusById(String userId, int id);
  Stream<List<int>> watchChangedIds(String userId);
  Future<void> updateWordStatusBatch(String userId, List<WordStatusDTO> list);

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
