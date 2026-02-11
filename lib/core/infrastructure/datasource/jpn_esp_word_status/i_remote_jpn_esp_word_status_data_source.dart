import 'package:my_dic/features/jpn_esp_word_status/data/jpn_esp_word_status_entity.dart';

abstract class IRemoteJpnEspWordStatusDataSource {
  Future<JpnEspWordStatusDTO?> getWordStatusById(String userId, int id);
  Future<List<JpnEspWordStatusDTO>> getWordStatusAfter(
      String userId, DateTime datetime);
  Future<void> updateWordStatus(String userId, JpnEspWordStatusDTO wordStatus);
  Stream<JpnEspWordStatusDTO> watchWordStatusById(String userId, int id);
  Stream<List<int>> watchChangedIds(String userId);
  Future<void> updateWordStatusBatch(String userId, List<JpnEspWordStatusDTO> list);
}
