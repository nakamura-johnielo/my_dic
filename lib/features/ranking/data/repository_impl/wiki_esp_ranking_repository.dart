import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/filtered_ranking_list_input_data.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';
import 'package:my_dic/features/ranking/domain/i_repository/i_esp_ranking_repository.dart';
import 'package:my_dic/features/ranking/data/data_source/local/ranking_dao.dart';

class WikiEspRankingRepository implements IEspRankingRepository {
  final RankingDao _rankingDao;
  WikiEspRankingRepository(this._rankingDao);

  @override
  Future<Result<List<Ranking>>> getRankingList(int page, int size) async {
    try {
      //log("############################################ranking dao");
      final res =
          await _rankingDao.getRankingListByPage(page = page, size = size);
      if (res == null) {
        return const Result.success([]);
      }

      final rankings = res.map((d) {
        return Ranking(
            rank: d.rankingNo,
            rankedWord: (d.word == null) ? "---" : d.word!,
            lemma: (d.wordOrigin == null) ? "---" : d.wordOrigin!,
            wordId: (d.wordId == null) ? -1 : d.wordId!);
      }).toList();
      return Result.success(rankings);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'ランキング取得に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
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
  Future<Result<List<Ranking>>> getRankingListByFilters(
      FilteredRankingListInputData input) async {
    try {
      final test = await _rankingDao.getRankingById(1);
      print("=====repo test word: ${test?.word}");
      print(
          " =====repo input requiredPage: ${input.requiredPage}, size: ${input.size}, posFilters: ${input.partOfSpeechFilters}, tagFilters: ${input.featureTagFilters}, posExclu: ${input.partOfSpeechExcludeFilters}, tagExclu: ${input.featureTagExcludeFilters}");
      final resp = await _rankingDao.getFilteredRankingWithStatusByPage(
          input.requiredPage,
          input.size,
          input.partOfSpeechFilters,
          input.featureTagFilters,
          input.partOfSpeechExcludeFilters,
          input.featureTagExcludeFilters);
      print("=====repo resp length: ${resp?.length}");
      if (resp == null || resp.isEmpty) {
        return const Result.success([]);
      }

      /* for (int i = 0; i < 20; i++) {
        log("word: ${rankings[i]}");
      } */
      final rankings = resp.map((data) {
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
      return Result.success(rankings);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'ランキングデータの取得に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
