import 'package:tuple/tuple.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';

abstract class IRankingLocalDataSource {
  Future<int?> getRankingNoById(int id);
    Future<int?> getRankingNoByWordId(int wordId);
    Future<Map<int, int>> getRankingNosByWordIds(List<int> wordIds);
  Future<RankingTableData?> getRankingById(int id);

  Future<List<RankingTableData>> getRankingListByPage(int page, int size);

  Future<List<RankingTableData>> getFilteredRankingListByPage(
      int requiredPage,
      int size,
      Set<PartOfSpeech> partOfSpeechFilters,
      Set<FeatureTag> featureTagFilters);

  Future<List<Tuple2<RankingTableData, EspJpnWordStatusTableData>>>
      getFilteredRankingWithStatusByPage(
          int requiredPage,
          int size,
          Set<PartOfSpeech> partOfSpeechFilters,
          Set<FeatureTag> featureTagFilters,
          Set<PartOfSpeech> partOfSpeechExcludeFilters,
          Set<FeatureTag> featureTagExcludeFilters);
}
