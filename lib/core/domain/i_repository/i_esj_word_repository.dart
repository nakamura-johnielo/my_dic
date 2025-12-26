import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';

abstract class IEsjWordRepository {
  Future<Result<List<EspJpnWord>>> getWordsByWord(String word);
  Future<Result<List<EspJpnWord>>> getWordsByWordByPage(
      String word, int size, int currentPage, bool forQuiz);
  Future<Result<List<EspJpnWord>>> getQuizWordsByWordByPage(
      String word, int size, int currentPage);
  Future<Result<void>> updateStatus(UpdateStatusRepositoryInputData input);

  Future<Result<WordStatus>> getStatusById(int wordId);
}
