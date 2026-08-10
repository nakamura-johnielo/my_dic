import 'package:my_dic/features/ranking/port/model/update_ranking_filter_input_data.dart';
import 'package:my_dic/features/ranking/port/model/update_ranking_filter_output_data.dart';

abstract class IUpdateRankingFilterUseCase {
  UpdateRankingFilterOutputData execute(UpdateRankingFilterInputData input);
}
