import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_dto.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';

abstract class IMyWordStatusRemoteDataSource {
  Future<MyWordStatusDTO?> getStatusById(String userId, String myWordId);
  Future<List<MyWordStatusDTO>> getStatusAfter(
      String userId, DateTime datetime);
  Future<RemoteMutationAck> patchStatus(RemoteMutationRequest request);
}
