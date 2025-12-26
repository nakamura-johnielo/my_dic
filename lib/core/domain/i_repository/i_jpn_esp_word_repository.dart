import 'package:my_dic/core/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/core/shared/utils/result.dart';

abstract class IJpnEspWordRepository {
  Future<Result<List<JpnEspWord>>> getWordsByWord(String word, int size, int page);
  Future<Result<void>> updateStatus(UpdateStatusRepositoryInputData input);
}
