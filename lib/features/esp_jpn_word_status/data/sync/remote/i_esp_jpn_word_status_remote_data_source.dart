import 'package:my_dic/features/esp_jpn_word_status/data/word_status_entity.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';

abstract interface class IEspJpnWordStatusRemoteDataSource {
  Future<WordStatusDTO?> getWordStatusById(String accountId, int wordId);
  Future<List<WordStatusDTO>> fetchPage(String accountId, SyncCursor? cursor);
  Future<RemoteMutationAck> patchWordStatus(RemoteMutationRequest request);
}
