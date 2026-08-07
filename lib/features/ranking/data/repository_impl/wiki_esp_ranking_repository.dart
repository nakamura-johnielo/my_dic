import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';
import 'package:my_dic/features/ranking/domain/i_repository/i_esp_ranking_repository.dart';
import 'package:my_dic/features/ranking/data/data_source/local/i_ranking_local_data_source.dart';

class RankingRepository implements IEspRankingRepository {
  final IRankingLocalDataSource _dataSource;
  RankingRepository(this._dataSource);
  @override
  Future<Result<Ranking>> getRankingById(int wordId) async {
    try {
      final data = await _dataSource.getRankingById(wordId);
      if (data == null) {
        return Result.failure(DatabaseError(
          message: 'ランキングが見つかりませんでした',
        ));
      }
      final entity = Ranking(
        rank: data.rankingNo,
        rankedWord: data.word ?? "",
        lemma: data.wordOrigin ?? "",
        wordId: data.wordId ?? -1,
        hasConj: data.hasConj == 1,
      );
      return Result.success(entity);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'ランキングの取得に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<List<Ranking>>> getRankingList(int page, int size) async {
    try {
      final dataList = await _dataSource.getRankingListByPage(page, size);
      final entities = dataList
          .map((data) => Ranking(
                rank: data.rankingNo,
                rankedWord: data.word ?? "",
                lemma: data.wordOrigin ?? "",
                wordId: data.wordId ?? -1,
              ))
          .toList();
      return Result.success(entities);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'ランキング取得に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<List<Ranking>>> getRankingListByFilters(
      int page,
      int size,
      Set<PartOfSpeech> partOfSpeechFilters,
      Set<FeatureTag> featureTagFilters,
      Set<PartOfSpeech> partOfSpeechExcludeFilters,
      Set<FeatureTag> featureTagExcludeFilters) async {
    try {
      // debug: removed direct DAO access
      AppLogger.print(
          " =====repo input requiredPage: $page, size: $size, posFilters: $partOfSpeechFilters, tagFilters: $featureTagFilters, posExclu: $partOfSpeechExcludeFilters, tagExclu: $featureTagExcludeFilters");
      final tupleList = await _dataSource.getFilteredRankingWithStatusByPage(
        page,
        size,
        partOfSpeechFilters,
        featureTagFilters,
        partOfSpeechExcludeFilters,
        featureTagExcludeFilters,
      );
      final entities = tupleList.map((tuple) {
        final rankingData = tuple.item1;
        final statusData = tuple.item2;
        return Ranking(
          rank: rankingData.rankingNo,
          rankedWord: rankingData.word ?? "",
          lemma: rankingData.wordOrigin ?? "",
          wordId: rankingData.wordId ?? -1,
          hasConj: rankingData.hasConj == 1,
          isLearned: statusData.isLearned == 1,
          isBookmarked: statusData.isBookmarked == 1,
        );
      }).toList();
      return Result.success(entities);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'ランキングデータの取得に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
