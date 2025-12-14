import 'package:my_dic/core/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';
import 'package:my_dic/core/domain/entity/word/esp_word.dart';

abstract class IEsjWordRepository {
  Future<List<EspJpnWord>> getWordsByWord(String word);
  Future<List<EspJpnWord>> getWordsByWordByPage(
      String word, int size, int currentPage, bool forQuiz);
  Future<List<EspJpnWord>> getQuizWordsByWordByPage(
      String word, int size, int currentPage);
  void updateStatus(UpdateStatusRepositoryInputData input);

  Future<WordStatus> getStatusById(int wordId);
}
