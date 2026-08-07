import 'package:my_dic/features/esp_jpn_word_status/data/sync/remote/firebase_word_status_dao.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/sync/remote/i_esp_jpn_word_status_remote_data_source.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/word_status_entity.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';

class FirebaseEspJpnWordStatusDataSource
    implements IEspJpnWordStatusRemoteDataSource {
  FirebaseEspJpnWordStatusDataSource(this._dao);

  final FirebaseWordStatusDao _dao;

  @override
  Future<WordStatusDTO?> getWordStatusById(String accountId, int wordId) =>
      _dao.getWordStatus(accountId, wordId);

  @override
  Future<List<WordStatusDTO>> fetchPage(String accountId, SyncCursor? cursor) =>
      _dao.fetchPage(accountId, cursor);

  @override
  Future<RemoteMutationAck> patchWordStatus(RemoteMutationRequest request) =>
      _dao.patch(request);
}
