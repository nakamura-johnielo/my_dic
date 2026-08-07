import 'package:my_dic/features/ranking/application/usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/features/ranking/application/usecase/update_ranking_filter/update_ranking_filter_input_data.dart';
import 'package:my_dic/features/ranking/application/usecase/update_ranking_filter/update_ranking_filter_output_data.dart';

class UpdateRankingFilterInteractor implements IUpdateRankingFilterUseCase {
  @override
  UpdateRankingFilterOutputData execute(UpdateRankingFilterInputData input) =>
      UpdateRankingFilterOutputData(input.data, input.filterType);
}
