import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/core/shared/utils/result.dart';

abstract class IJpnEspWordRepository {
  Future<Result<List<JpnEspWord>>> getWordsByWord(
      String word, int size, int page);

  Future<Result<Map<int, int>>> getStarCountsByWordIds(List<int> wordIds);
  Future<Result<Map<int, String>>> getSimpleMeaningsByWordIds(
      List<int> wordIds);
  Future<Result<Map<int, int>>> getRankingNosByWordIds(List<int> wordIds);
}
