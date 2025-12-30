import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/filtered_ranking_list_input_data.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';
import 'package:my_dic/features/ranking/domain/i_repository/i_esp_ranking_repository.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';

class LoadRankingsInteractor implements ILoadRankingsUseCase {
  // final ILoadRankingsPresenter _loadRankingsPresenterImpl;
  final IEspRankingRepository _wikiEspRankingRepository;

  LoadRankingsInteractor(
      // this._loadRankingsPresenterImpl,
      this._wikiEspRankingRepository);
/*   int _getOffset(int pagenation, int size) {
    return pagenation ~/ size; //商のみ
  } */

  @override
  Future<Result<List<Ranking>>> execute(LoadRankingsInputData input) async {
    // バリデーション
    // if (input.size <= 0) {
    //   return Result.failure(ValidationError(
    //     message: 'ページサイズは1以上である必要があります',
    //   ));
    // }

    try {
      List<int> requiredPages = [input.currentPage[0], input.currentPage[1]];
      int offset = input.pagenation; // getOffset(input.pagenation, input.size);
    /* if ((offset < requiredPages[0] || -1 == requiredPages[0]) ||
        requiredPages[1] < offset) */

    //TODO 両方に行けるscrollではない
    //現状、Next方向のみ対応
    requiredPages[1] += 1;
    final requiredNextPage = requiredPages[1] + offset;

    // if (requiredPages[0] <= offset && offset <= requiredPages[1]) {
    //   if (input.isNext) {
    //     requiredPages[1] += 1;
    //   } else {
    //     requiredPages[0] -= 1;
    //   }
    // } else {
    //   requiredPages[0] = offset;
    //   requiredPages[1] = offset;
    // }


    /* if (input.isNext) {
      if (offset <= requiredPages[1]) {
        requiredPages[1] += 1;
      } else {
        requiredPages[1] = offset;
        requiredPages[0] = offset;
      }
    } else {
      if (offset >= requiredPages[0]) {
        requiredPages[0] -= 1;
      } else {
        requiredPages[0] = offset;
        requiredPages[1] = offset;
      }
    } */
    // 結果を格納するセット
    Set<PartOfSpeech> partOfSpeechFilter = {};
    Set<PartOfSpeech> partOfSpeechExcludeFilter = {};
    // マップをループして分ける
    input.partOfSpeechFilters.forEach((key, value) {
      if (value == 1) {
        partOfSpeechFilter.add(key);
      } else if (value == -1) {
        partOfSpeechExcludeFilter.add(key);
      }
    });
    // 結果を格納するセット
    Set<FeatureTag> featureTagFilter = {};
    Set<FeatureTag> featureTagExcludeFilter = {};
    // マップをループして分ける
    input.featureTagFilters.forEach((key, value) {
      if (value == 1) {
        featureTagFilter.add(key);
      } else if (value == -1) {
        featureTagExcludeFilter.add(key);
      }
    });

    FilteredRankingListInputData inputData = FilteredRankingListInputData(
        partOfSpeechFilter,
        featureTagFilter,
        partOfSpeechExcludeFilter,
        featureTagExcludeFilter,
        input.isNext
            ? requiredNextPage//requiredPages[1]
            : requiredPages[0], //current -> required
        input.size);

    final result =
        await _wikiEspRankingRepository.getRankingListByFilters(inputData);

    return result;
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'ランキングデータの取得に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
    // LoadRankingsOutputData outputData =
    //     LoadRankingsOutputData(resp, requiredPages);
    // if (input.isNext) {
    //   _loadRankingsPresenterImpl.handleNext(outputData);
    //   return;
    // }
    // _loadRankingsPresenterImpl.handlePrevious(outputData);
  }
}
