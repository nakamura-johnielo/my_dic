import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/esp_jpn_word_status_dto.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/firebase_esp_jpn_word_status_dao.dart';

/// Remote-store facade used by the Esp-Jpn synchronization adapter.
final class FirebaseEspJpnWordStatusRemoteStore {
  FirebaseEspJpnWordStatusRemoteStore(this._dao);

  final FirebaseEspJpnWordStatusDao _dao;

  Future<EspJpnWordStatusDto?> getWordStatusById(
          String accountId, int wordId) =>
      _dao.getWordStatus(accountId, wordId);

  Future<List<EspJpnWordStatusDto>> fetchPage(
    String accountId,
    SyncCursor? cursor,
  ) =>
      _dao.fetchPage(accountId, cursor);

  Future<RemoteMutationAck> patchWordStatus(RemoteMutationRequest request) =>
      _dao.patch(request);
}
