import 'package:my_dic/_Business_Rule/Usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';

abstract class IJpnEspWordRepository {
  Future<List<JpnEspWord>> getWordsByWord(String word, int size, int page);
  void updateStatus(UpdateStatusRepositoryInputData input);
}
