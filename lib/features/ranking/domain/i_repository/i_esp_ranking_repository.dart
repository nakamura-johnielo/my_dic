import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';

abstract class IEspRankingRepository {
  Future<Result<List<Ranking>>> getRankingList(int page, int size);
  Future<Result<List<Ranking>>> getRankingListByFilters(
    int page,
    int size,
    Set<PartOfSpeech> partOfSpeechFilters,
    Set<FeatureTag> featureTagFilters,
    Set<PartOfSpeech> partOfSpeechExcludeFilters,
    Set<FeatureTag> featureTagExcludeFilters,
  );
  Future<Result<Ranking>> getRankingById(int wordId);
}
