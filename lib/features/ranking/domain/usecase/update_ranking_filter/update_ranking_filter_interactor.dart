import 'package:my_dic/core/shared/enums/i_enum.dart';
import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/update_ranking_filter_input_data.dart';
import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/update_ranking_filter_output_data.dart';

class UpdateRankingFilterInteractor implements IUpdateRankingFilterUseCase {
  UpdateRankingFilterInteractor();

  @override
  UpdateRankingFilterOutputData execute(UpdateRankingFilterInputData input) {
    DisplayEnumMixin data = input.data;
    int filterType = input.filterType;

    return UpdateRankingFilterOutputData(data, filterType);
  }
}
