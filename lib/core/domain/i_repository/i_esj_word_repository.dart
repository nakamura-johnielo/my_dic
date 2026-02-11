import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';

abstract class IEsjWordRepository {
  Future<Result<List<EspJpnWord>>> getWordsByWord(String word);
  Future<Result<List<EspJpnWord>>> getWordsByWordByPage(
      String word, int size, int currentPage, bool forQuiz);
  Future<Result<List<EspJpnWord>>> getQuizWordsByWordByPage(
      String word, int size, int currentPage);
      Future<Result<int>> getStarCountById(int id);
      Future<Result<String>> getSimpleMeaningById(int id);
      Future<Result<int>> getRankingNoById(int id);

    // wordId based (bulk)
    Future<Result<Map<int, int>>> getStarCountsByWordIds(List<int> wordIds);
    Future<Result<Map<int, String>>> getSimpleMeaningsByWordIds(List<int> wordIds);
    Future<Result<Map<int, int>>> getRankingNosByWordIds(List<int> wordIds);

}
