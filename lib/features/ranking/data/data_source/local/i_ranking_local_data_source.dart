import 'package:my_dic/features/ranking/domain/entity/ranking.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';

abstract class IRankingLocalDataSource {
  Future<Ranking?> getRankingById(int id);

  Future<List<Ranking>> getRankingListByPage(int page, int size);

  Future<List<Ranking>> getFilteredRankingListByPage(
      int requiredPage,
      int size,
      Set<PartOfSpeech> partOfSpeechFilters,
      Set<FeatureTag> featureTagFilters);

  Future<List<Ranking>> getFilteredRankingWithStatusByPage(
      int requiredPage,
      int size,
      Set<PartOfSpeech> partOfSpeechFilters,
      Set<FeatureTag> featureTagFilters,
      Set<PartOfSpeech> partOfSpeechExcludeFilters,
      Set<FeatureTag> featureTagExcludeFilters);
}
