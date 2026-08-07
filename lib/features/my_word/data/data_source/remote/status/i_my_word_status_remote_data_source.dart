import 'package:my_dic/features/my_word/data/data_source/remote/status/firebase_my_word_status_dto.dart';

abstract class IMyWordStatusRemoteDataSource {
  Future<MyWordStatusDTO?> getStatusById(String userId, String myWordId);
  Future<List<MyWordStatusDTO>> getStatusAfter(String userId, DateTime datetime);
  Future<void> updateStatus(String userId, MyWordStatusDTO status);
  Stream<List<String>> watchChangedIds(String userId);
  Future<void> updateStatusBatch(String userId, List<MyWordStatusDTO> statusList);
  Future<void> deleteStatus(String userId, String myWordId);

  /// Writes only the fields named in [fieldMask], leaving every other remote
  /// field untouched. [isNew] controls whether `createdAt` is also stamped.
  Future<void> patchStatus(
    String userId,
    String myWordId,
    Map<String, Object?> fields,
    List<String> fieldMask, {
    required bool isNew,
  });
}
