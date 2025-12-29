import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_repository_input_data.dart';

abstract class IJpnEspWordLocalDataSource {
  Future<List<JpnEspWord>> getWordsByWord(String word, int size, int currentPage);
  Future<void> updateStatus(UpdateStatusRepositoryInputData input);
}
