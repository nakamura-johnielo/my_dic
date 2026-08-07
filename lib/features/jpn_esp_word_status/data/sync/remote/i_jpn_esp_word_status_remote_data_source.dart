import 'package:my_dic/features/jpn_esp_word_status/data/jpn_esp_word_status_entity.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';

abstract interface class IJpnEspWordStatusRemoteDataSource {
  Future<JpnEspWordStatusDTO?> getWordStatusById(String accountId, int wordId);
  Future<List<JpnEspWordStatusDTO>> fetchPage(
      String accountId, SyncCursor? cursor);
  Future<RemoteMutationAck> patchWordStatus(RemoteMutationRequest request);
}
