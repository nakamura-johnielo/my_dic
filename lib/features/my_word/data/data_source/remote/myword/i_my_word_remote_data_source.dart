import 'package:my_dic/features/my_word/data/data_source/remote/myword/firebase_my_word_dto.dart';

abstract class IMyWordRemoteDataSource {
  Future<MyWordDTO?> getMyWordById(String userId, String myWordId);
  Future<List<MyWordDTO>> getMyWordsAfter(String userId, DateTime datetime);
  Future<void> updateMyWord(String userId, MyWordDTO myWord);
  Stream<List<String>> watchChangedIds(String userId);
  Future<void> updateMyWordBatch(String userId, List<MyWordDTO> myWordList);
  Future<void> deleteMyWord(String userId, String myWordId);

  /// Writes only the fields named in [fieldMask], leaving every other remote
  /// field untouched. [isNew] controls whether `createdAt` is also stamped.
  Future<void> patchMyWord(
    String userId,
    String myWordId,
    Map<String, Object?> fields,
    List<String> fieldMask, {
    required bool isNew,
  });
}
