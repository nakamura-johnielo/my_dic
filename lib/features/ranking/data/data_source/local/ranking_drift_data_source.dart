import 'package:tuple/tuple.dart';
import 'package:my_dic/features/ranking/data/data_source/local/ranking_dao.dart';
import 'package:my_dic/features/ranking/data/data_source/local/rankings_entity.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';
import 'package:my_dic/features/ranking/data/data_source/local/i_ranking_local_data_source.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';

class RankingDriftDataSource implements IRankingLocalDataSource {
  final RankingDao _dao;
  RankingDriftDataSource(this._dao);

  @override
  Future<Ranking?> getRankingById(int id) async {
    final data = await _dao.getRankingById(id);
    if (data == null) return null;
    return Ranking(
      rank: data.rankingNo,
      rankedWord: data.word ?? "---",
      lemma: data.wordOrigin ?? "---",
      wordId: data.wordId ?? -1,
      hasConj: data.hasConj == 1,
    );
  }

  @override
  Future<List<Ranking>> getRankingListByPage(int page, int size) async {
    final list = await _dao.getRankingListByPage(page, size);
    return list.map((d) {
      return Ranking(
        rank: d.rankingNo,
        rankedWord: d.word ?? "---",
        lemma: d.wordOrigin ?? "---",
        wordId: d.wordId ?? -1,
        hasConj: d.hasConj == 1,
      );
    }).toList();
  }

  @override
  Future<List<Ranking>> getFilteredRankingListByPage(
      int requiredPage,
      int size,
      Set<PartOfSpeech> partOfSpeechFilters,
      Set<FeatureTag> featureTagFilters) async {
    final list = await _dao.getFilteredRankingListByPage(
        requiredPage, size, partOfSpeechFilters, featureTagFilters);
    return list.map((d) {
      return Ranking(
        rank: d.rankingNo,
        rankedWord: d.word ?? "",
        lemma: d.wordOrigin ?? "",
        wordId: d.wordId ?? -1,
        hasConj: d.hasConj == 1,
      );
    }).toList();
  }

  @override
  Future<List<Ranking>> getFilteredRankingWithStatusByPage(
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
    if (resp == null || resp.isEmpty) return [];
    return resp.map((tuple) {
      final r = tuple.item1;
      final s = tuple.item2;
      return Ranking(
        rank: r.rankingNo,
        rankedWord: r.word ?? "",
        lemma: r.wordOrigin ?? "",
        wordId: r.wordId ?? -1,
        isLearned: s.isLearned == 1,
        isBookmarked: s.isBookmarked == 1,
        hasNote: s.hasNote == 1,
        hasConj: r.hasConj == 1,
      );
    }).toList();
  }
}
