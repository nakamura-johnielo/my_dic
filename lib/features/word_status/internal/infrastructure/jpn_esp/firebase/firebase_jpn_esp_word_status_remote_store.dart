import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/firebase_jpn_esp_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/jpn_esp_word_status_dto.dart';

/// Remote-store facade used by the Jpn-Esp synchronization adapter.
final class FirebaseJpnEspWordStatusRemoteStore {
  FirebaseJpnEspWordStatusRemoteStore(this._dao);

  final FirebaseJpnEspWordStatusDao _dao;

  Future<JpnEspWordStatusDto?> getWordStatusById(
          String accountId, int wordId) =>
      _dao.getWordStatus(accountId, wordId);

  Future<List<JpnEspWordStatusDto>> fetchPage(
    String accountId,
    SyncCursor? cursor,
  ) =>
      _dao.fetchPage(accountId, cursor);

  Future<RemoteMutationAck> patchWordStatus(RemoteMutationRequest request) =>
      _dao.patch(request);
}
