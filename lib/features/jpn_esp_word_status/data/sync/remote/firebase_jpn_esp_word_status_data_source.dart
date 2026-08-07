import 'package:my_dic/features/jpn_esp_word_status/data/sync/remote/firebase_jpn_esp_word_status_dao.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/jpn_esp_word_status_entity.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/sync/remote/i_jpn_esp_word_status_remote_data_source.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';

class FirebaseJpnEspWordStatusDataSource
    implements IJpnEspWordStatusRemoteDataSource {
  FirebaseJpnEspWordStatusDataSource(this._dao);

  final FirebaseJpnEspWordStatusDao _dao;

  @override
  Future<JpnEspWordStatusDTO?> getWordStatusById(
          String accountId, int wordId) =>
      _dao.getWordStatus(accountId, wordId);

  @override
  Future<List<JpnEspWordStatusDTO>> fetchPage(
          String accountId, SyncCursor? cursor) =>
      _dao.fetchPage(accountId, cursor);

  @override
  Future<RemoteMutationAck> patchWordStatus(RemoteMutationRequest request) =>
      _dao.patch(request);
}
