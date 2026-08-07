import 'package:my_dic/features/my_word/data/sync/remote/status/firebase_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/data/sync/remote/status/firebase_my_word_status_dto.dart';
import 'package:my_dic/features/my_word/data/sync/remote/status/i_my_word_status_remote_data_source.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';

class FirebaseMyWordStatusDataSource implements IMyWordStatusRemoteDataSource {
  final FirebaseMyWordStatusDao _dao;
  FirebaseMyWordStatusDataSource(this._dao);

  @override
  Future<MyWordStatusDTO?> getStatusById(String userId, String myWordId) async {
    return await _dao.getStatus(userId, myWordId);
  }

  @override
  Future<List<MyWordStatusDTO>> getStatusAfter(
      String userId, DateTime datetime) async {
    return await _dao.getStatusAfter(userId, datetime);
  }

  @override
  Future<RemoteMutationAck> patchStatus(RemoteMutationRequest request) {
    return _dao.patch(request);
  }
}
