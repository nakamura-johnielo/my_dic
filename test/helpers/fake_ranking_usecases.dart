import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/application/query/ranking_page.dart';
import 'package:my_dic/features/ranking/application/usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/features/ranking/application/usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/application/usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/features/ranking/application/usecase/update_ranking_filter/update_ranking_filter_input_data.dart';
import 'package:my_dic/features/ranking/application/usecase/update_ranking_filter/update_ranking_filter_output_data.dart';

class FakeLoadRankingsUseCase implements ILoadRankingsUseCase {
  Result<RankingPage> _result;

  FakeLoadRankingsUseCase({required Result<RankingPage> result})
      : _result = result;

  void setResult(Result<RankingPage> result) {
    _result = result;
  }

  @override
  Future<Result<RankingPage>> execute(LoadRankingsInputData input) async {
    return _result;
  }
}

class FakeUpdateRankingFilterUseCase implements IUpdateRankingFilterUseCase {
  @override
  UpdateRankingFilterOutputData execute(UpdateRankingFilterInputData input) {
    return UpdateRankingFilterOutputData(input.data, input.filterType);
  }
}
