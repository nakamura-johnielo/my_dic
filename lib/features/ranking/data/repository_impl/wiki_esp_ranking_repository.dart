import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/filtered_ranking_list_input_data.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';
import 'package:my_dic/features/ranking/domain/i_repository/i_esp_ranking_repository.dart';
import 'package:my_dic/features/ranking/data/data_source/local/i_ranking_local_data_source.dart';


class WikiEspRankingRepository implements IEspRankingRepository {
  final IRankingLocalDataSource _dataSource;
  WikiEspRankingRepository(this._dataSource);

  @override
  Future<Result<List<Ranking>>> getRankingList(int page, int size) async {
    try {
      //log("############################################ranking dao");
      final res = await _dataSource.getRankingListByPage(page, size);
      return Result.success(res);
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
      // debug: removed direct DAO access
      print(
          " =====repo input requiredPage: ${input.requiredPage}, size: ${input.size}, posFilters: ${input.partOfSpeechFilters}, tagFilters: ${input.featureTagFilters}, posExclu: ${input.partOfSpeechExcludeFilters}, tagExclu: ${input.featureTagExcludeFilters}");
      final resp = await _dataSource.getFilteredRankingWithStatusByPage(
        input.requiredPage,
        input.size,
        input.partOfSpeechFilters,
        input.featureTagFilters,
        input.partOfSpeechExcludeFilters,
        input.featureTagExcludeFilters,
      );
      return Result.success(resp);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'ランキングデータの取得に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
