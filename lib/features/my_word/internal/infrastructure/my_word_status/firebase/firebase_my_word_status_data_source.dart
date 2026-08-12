import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_dto.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/i_my_word_status_remote_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/mapper/my_word_infrastructure_error_mapper.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';

class FirebaseMyWordStatusDataSource implements IMyWordStatusRemoteDataSource {
  final FirebaseMyWordStatusDao _dao;
  FirebaseMyWordStatusDataSource(this._dao);

  @override
  Future<MyWordStatusDTO?> getStatusById(String userId, String myWordId) async {
    try {
      return await _dao.getStatus(userId, myWordId);
    } catch (error, stackTrace) {
      throw MyWordInfrastructureErrorMapper.firebase(
        error,
        stackTrace,
        message: 'Failed to load my word status from Firebase.',
      );
    }
  }

  @override
  Future<List<MyWordStatusDTO>> getStatusAfter(
      String userId, DateTime datetime) async {
    try {
      return await _dao.getStatusAfter(userId, datetime);
    } catch (error, stackTrace) {
      throw MyWordInfrastructureErrorMapper.firebase(
        error,
        stackTrace,
        message: 'Failed to load my word statuses from Firebase.',
      );
    }
  }

  @override
  Future<RemoteMutationAck> patchStatus(RemoteMutationRequest request) {
    return _dao
        .patch(request)
        .catchError((Object error, StackTrace stackTrace) {
      throw MyWordInfrastructureErrorMapper.firebase(
        error,
        stackTrace,
        message: 'Failed to update my word status in Firebase.',
      );
    });
  }
}
