import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dto.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/i_my_word_remote_data_source.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';

class FirebaseMyWordDataSource implements IMyWordRemoteDataSource {
  final FirebaseMyWordDao _dao;
  FirebaseMyWordDataSource(this._dao);

  @override
  Future<MyWordDTO?> getMyWordById(String userId, String myWordId) async {
    return await _dao.getMyWord(userId, myWordId);
  }

  @override
  Future<List<MyWordDTO>> getMyWordsAfter(
      String userId, DateTime datetime) async {
    return await _dao.getMyWordsAfter(userId, datetime);
  }

  @override
  Future<RemoteMutationAck> patchMyWord(RemoteMutationRequest request) {
    return _dao.patch(request);
  }
}
