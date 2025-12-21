import 'package:my_dic/features/ranking/domain/entity/ranking.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/load_rankings_input_data.dart';

abstract class ILoadRankingsUseCase {
  Future<List<Ranking>> execute(LoadRankingsInputData input);
}
