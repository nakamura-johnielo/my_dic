import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dto.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/i_my_word_remote_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/mapper/my_word_infrastructure_error_mapper.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';

class FirebaseMyWordDataSource implements IMyWordRemoteDataSource {
  final FirebaseMyWordDao _dao;
  FirebaseMyWordDataSource(this._dao);

  @override
  Future<MyWordDTO?> getMyWordById(String userId, String myWordId) async {
    try {
      return await _dao.getMyWord(userId, myWordId);
    } catch (error, stackTrace) {
      throw MyWordInfrastructureErrorMapper.firebase(
        error,
        stackTrace,
        message: 'Failed to load my word from Firebase.',
      );
    }
  }

  @override
  Future<List<MyWordDTO>> getMyWordsAfter(
      String userId, DateTime datetime) async {
    try {
      return await _dao.getMyWordsAfter(userId, datetime);
    } catch (error, stackTrace) {
      throw MyWordInfrastructureErrorMapper.firebase(
        error,
        stackTrace,
        message: 'Failed to load my words from Firebase.',
      );
    }
  }

  @override
  Future<RemoteMutationAck> patchMyWord(RemoteMutationRequest request) {
    return _dao
        .patch(request)
        .catchError((Object error, StackTrace stackTrace) {
      throw MyWordInfrastructureErrorMapper.firebase(
        error,
        stackTrace,
        message: 'Failed to update my word in Firebase.',
      );
    });
  }
}
