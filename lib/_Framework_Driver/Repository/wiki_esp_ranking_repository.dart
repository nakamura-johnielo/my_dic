import 'package:my_dic/_Business_Rule/Usecase/load_rankings/filtered_ranking_list_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esp_ranking_repository.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/ranking_dao.dart';

class WikiEspRankingRepository implements IEspRankingRepository {
  final RankingDao _rankingDao;
  WikiEspRankingRepository(this._rankingDao);

  @override
  Future<List<Ranking>> getRankingList(int page, int size) async {
    //log("############################################ranking dao");
    final res =
        await _rankingDao.getRankingListByPage(page = page, size = size);
    if (res == null) {
      List<Ranking> l = [];
      return l;
    }

    return res.map((d) {
      return Ranking(
          rank: d.rankingNo,
          rankedWord: (d.word == null) ? "---" : d.word!,
          lemma: (d.wordOrigin == null) ? "---" : d.wordOrigin!,
          wordId: (d.wordId == null) ? -1 : d.wordId!);
    }).toList();
  }

  /* @override
  Future<List<Ranking>> getRankingListByFilters(
      FilteredRankingListInputData input) async {
    final rankings = await _rankingDao.getFilteredRankingListByPage(
        input.requiredPage,
        input.size,
        input.partOfSpeechFilters,
        input.featureTagFilters);

    if (rankings == null || rankings.isEmpty) {
      List<Ranking> res = [];
      return res;
    }

    /* for (int i = 0; i < 20; i++) {
      log("word: ${rankings[i]}");
    } */
    return rankings.map((ranking) {
      return Ranking(
        rank: ranking.rankingNo,
        rankedWord: ranking.word ?? "",
        lemma: ranking.wordOrigin ?? "",
        wordId: ranking.wordId ?? -1,
      );
    }).toList();
  }
 */
  @override
  Future<List<Ranking>> getRankingListByFilters(
      FilteredRankingListInputData input) async {
    final resp = await _rankingDao.getFilteredRankingWithStatusByPage(
        input.requiredPage,
        input.size,
        input.partOfSpeechFilters,
        input.featureTagFilters,
        input.partOfSpeechExcludeFilters,
        input.featureTagExcludeFilters);

    if (resp == null || resp.isEmpty) {
      List<Ranking> res = [];
      return res;
    }

    /* for (int i = 0; i < 20; i++) {
      log("word: ${rankings[i]}");
    } */
    return resp.map((data) {
      return Ranking(
        rank: data.item1.rankingNo,
        rankedWord: data.item1.word ?? "",
        lemma: data.item1.wordOrigin ?? "",
        wordId: data.item1.wordId ?? -1,
        isLearned: data.item2.isLearned == 1,
        isBookmarked: data.item2.isBookmarked == 1,
        hasNote: data.item2.hasNote == 1,
        hasConj: data.item1.hasConj == 1,
      );
    }).toList();
  }
}
