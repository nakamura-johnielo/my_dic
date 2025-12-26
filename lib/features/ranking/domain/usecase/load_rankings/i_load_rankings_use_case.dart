import 'package:my_dic/features/ranking/domain/entity/ranking.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/core/shared/utils/result.dart';

abstract class ILoadRankingsUseCase {
  Future<Result<List<Ranking>>> execute(LoadRankingsInputData input);
}
