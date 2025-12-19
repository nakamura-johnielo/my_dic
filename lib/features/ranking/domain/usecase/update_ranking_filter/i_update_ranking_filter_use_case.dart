import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/update_ranking_filter_input_data.dart';

abstract class IUpdateRankingFilterUseCase {
  void execute(UpdateRankingFilterInputData input);
}
