import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_repository_input_data.dart';

abstract class IEsjWordLocalDataSource {
  Future<List<EspJpnWordTableData>> getWordsByWord(String word);
  // Future<void> updateStatus(UpdateStatusRepositoryInputData input);

  Future<List<EspJpnWordTableData>> getWordsByWordByPage(
      String word, int size, int currentPage, bool forQuiz);
  Future<List<EspJpnWordTableData>> getQuizWordsByWordByPage(
      String word, int size, int currentPage);
}
