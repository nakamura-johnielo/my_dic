import 'package:tuple/tuple.dart';
import 'package:my_dic/features/ranking/data/data_source/local/ranking_dao.dart';
import 'package:my_dic/features/ranking/data/data_source/local/rankings_entity.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/ranking/data/data_source/local/i_ranking_local_data_source.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';

class RankingDriftDataSource implements IRankingLocalDataSource {
  final RankingDao _dao;
  RankingDriftDataSource(this._dao);

  @override
  Future<RankingTableData?> getRankingById(int id) async {
    return await _dao.getRankingById(id);
  }

  @override
  Future<List<RankingTableData>> getRankingListByPage(int page, int size) async {
    return await _dao.getRankingListByPage(page, size);
  }

  @override
  Future<List<RankingTableData>> getFilteredRankingListByPage(
      int requiredPage,
      int size,
      Set<PartOfSpeech> partOfSpeechFilters,
      Set<FeatureTag> featureTagFilters) async {
    return await _dao.getFilteredRankingListByPage(
        requiredPage, size, partOfSpeechFilters, featureTagFilters);
  }

  @override
  Future<List<Tuple2<RankingTableData, EspJpnWordStatusTableData>>> getFilteredRankingWithStatusByPage(
      int requiredPage,
      int size,
      Set<PartOfSpeech> partOfSpeechFilters,
      Set<FeatureTag> featureTagFilters,
      Set<PartOfSpeech> partOfSpeechExcludeFilters,
      Set<FeatureTag> featureTagExcludeFilters) async {
    final resp = await _dao.getFilteredRankingWithStatusByPage(
      requiredPage,
      size,
      partOfSpeechFilters,
      featureTagFilters,
      partOfSpeechExcludeFilters,
      featureTagExcludeFilters,
    );
    return resp ?? [];
  }
}
