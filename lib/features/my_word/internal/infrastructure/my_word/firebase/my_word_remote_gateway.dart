import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dto.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

abstract interface class MyWordRemoteGateway {
  Future<MyWordDTO?> getMyWordById(String userId, String myWordId);
  Future<List<MyWordDTO>> getMyWordsAfter(String userId, DateTime datetime);
  Future<RemoteMutationAck> patchMyWord(RemoteMutationRequest request);
}
