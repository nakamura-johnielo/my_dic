import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dto.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';

abstract class IMyWordRemoteDataSource {
  Future<MyWordDTO?> getMyWordById(String userId, String myWordId);
  Future<List<MyWordDTO>> getMyWordsAfter(String userId, DateTime datetime);
  Future<RemoteMutationAck> patchMyWord(RemoteMutationRequest request);
}
