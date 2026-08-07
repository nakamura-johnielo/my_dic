import 'package:my_dic/features/esp_jpn_word_status/data/word_status_entity.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';

abstract class IRemoteWordStatusDataSource {
  Future<WordStatusDTO?> getWordStatusById(String userId, int id);
  Future<List<WordStatusDTO>> getWordStatusAfter(
      String userId, DateTime datetime);
  Future<void> updateWordStatus(String userId, WordStatusDTO wordStatus);
  Stream<WordStatusDTO> watchWordStatusById(String userId, int id);
  Stream<List<int>> watchChangedIds(String userId);
  Future<void> updateWordStatusBatch(String userId, List<WordStatusDTO> list);

  Future<RemoteMutationAck> patchWordStatus(RemoteMutationRequest request);
}
