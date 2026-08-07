import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/application/usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';

abstract class ILoadRankingsUseCase {
  Future<Result<List<Ranking>>> execute(LoadRankingsInputData input);
}
