import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';

abstract class IEsjWordRepository {
  Future<Result<List<EspJpnWord>>> getWordsByWord(String word);
  Future<Result<List<EspJpnWord>>> getWordsByWordByPage(
      String word, int size, int currentPage, bool forQuiz);
  Future<Result<List<EspJpnWord>>> getQuizWordsByWordByPage(
      String word, int size, int currentPage);
}
