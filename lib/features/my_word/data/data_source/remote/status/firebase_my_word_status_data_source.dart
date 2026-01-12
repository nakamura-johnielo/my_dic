import 'package:my_dic/features/my_word/data/data_source/remote/status/firebase_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/status/firebase_my_word_status_dto.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/status/i_my_word_status_remote_data_source.dart';

class FirebaseMyWordStatusDataSource
    implements IMyWordStatusRemoteDataSource {
  final FirebaseMyWordStatusDao _dao;
  FirebaseMyWordStatusDataSource(this._dao);

  @override
  Future<MyWordStatusDTO?> getStatusById(String userId, int myWordId) async {
    return await _dao.getStatus(userId, myWordId);
  }

  @override
  Future<List<MyWordStatusDTO>> getStatusAfter(
      String userId, DateTime datetime) async {
    return await _dao.getStatusAfter(userId, datetime);
  }

  @override
  Future<void> updateStatus(String userId, MyWordStatusDTO status) async {
    await _dao.update(status, userId);
  }

  @override
  Stream<List<int>> watchChangedIds(String userId) =>
      _dao.watchChangedStatusIds(userId);

  @override
  Future<void> updateStatusBatch(
      String userId, List<MyWordStatusDTO> statusList) async {
    await _dao.updateBatch(userId, statusList);
  }

  @override
  Future<void> deleteStatus(String userId, int myWordId) async {
    await _dao.delete(userId, myWordId);
  }
}
