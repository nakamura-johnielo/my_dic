import 'package:my_dic/_Business_Rule/Usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word/word.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word/word_status.dart';

abstract class IEsjWordRepository {
  Future<List<Word>> getWordsByWord(String word);
  Future<List<Word>> getWordsByWordByPage(
      String word, int size, int currentPage, bool forQuiz);
  Future<List<Word>> getQuizWordsByWordByPage(
      String word, int size, int currentPage);
  void updateStatus(UpdateStatusRepositoryInputData input);

  Future<WordStatus> getStatusById(int wordId);
}
