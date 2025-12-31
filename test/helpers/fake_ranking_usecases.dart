import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/domain/usecase/locate_ranking_pagenation/i_locate_ranking_pagenation_use_case.dart';
import 'package:my_dic/features/ranking/domain/usecase/locate_ranking_pagenation/locate_ranking_pagenation_input_data.dart';
import 'package:my_dic/features/ranking/domain/usecase/locate_ranking_pagenation/locate_ranking_pagenation_output_data.dart';
import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/update_ranking_filter_input_data.dart';
import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/update_ranking_filter_output_data.dart';

class FakeLoadRankingsUseCase implements ILoadRankingsUseCase {
  Result<List<Ranking>> _result;

  FakeLoadRankingsUseCase({required Result<List<Ranking>> result})
      : _result = result;

  void setResult(Result<List<Ranking>> result) {
    _result = result;
  }

  @override
  Future<Result<List<Ranking>>> execute(LoadRankingsInputData input) async {
    return _result;
  }
}

class FakeLocateRankingPagenationUseCase
    implements ILocateRankingPagenationUseCase {
  @override
  Future<LocateRankingPagenationOutputData> execute(
      LocateRankingPagenationInputData input) async {
    return LocateRankingPagenationOutputData(input.pagenationFilter);
  }
}

class FakeUpdateRankingFilterUseCase implements IUpdateRankingFilterUseCase {
  @override
  UpdateRankingFilterOutputData execute(UpdateRankingFilterInputData input) {
    return UpdateRankingFilterOutputData(input.data, input.filterType);
  }
}
