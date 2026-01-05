import 'package:my_dic/core/infrastructure/dtos/wordStatusEntity.dart';

abstract class IRemoteWordStatusDataSource {
  Future<WordStatusDTO?> getWordStatusById(String userId, int id);
  Future<List<WordStatusDTO>> getWordStatusAfter(String userId, DateTime datetime);
  Future<void> updateWordStatus(String userId, WordStatusDTO wordStatus);
  Stream<WordStatusDTO> watchWordStatusById(String userId, int id);
  Stream<List<int>> watchChangedIds(String userId);
  Future<void> updateWordStatusBatch(String userId, List<WordStatusDTO> list);
}
