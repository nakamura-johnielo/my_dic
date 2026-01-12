import 'package:my_dic/features/my_word/data/data_source/remote/status/firebase_my_word_status_dto.dart';

abstract class IMyWordStatusRemoteDataSource {
  Future<MyWordStatusDTO?> getStatusById(String userId, int myWordId);
  Future<List<MyWordStatusDTO>> getStatusAfter(String userId, DateTime datetime);
  Future<void> updateStatus(String userId, MyWordStatusDTO status);
  Stream<List<int>> watchChangedIds(String userId);
  Future<void> updateStatusBatch(String userId, List<MyWordStatusDTO> statusList);
  Future<void> deleteStatus(String userId, int myWordId);
}
