import 'package:my_dic/features/my_word/data/sync/remote/myword/firebase_my_word_dto.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';

abstract class IMyWordRemoteDataSource {
  Future<MyWordDTO?> getMyWordById(String userId, String myWordId);
  Future<List<MyWordDTO>> getMyWordsAfter(String userId, DateTime datetime);
  Future<RemoteMutationAck> patchMyWord(RemoteMutationRequest request);
}
