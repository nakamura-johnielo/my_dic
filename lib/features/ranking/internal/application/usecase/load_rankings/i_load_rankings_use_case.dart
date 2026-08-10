import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/port/model/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/port/model/ranking_page.dart';

abstract class ILoadRankingsUseCase {
  Future<Result<RankingPage>> execute(LoadRankingsInputData input);
}
