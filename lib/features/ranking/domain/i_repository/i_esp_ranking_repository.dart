import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/filtered_ranking_list_input_data.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';

abstract class IEspRankingRepository {
  Future<Result<List<Ranking>>> getRankingList(int page, int size);
  Future<Result<List<Ranking>>> getRankingListByFilters(
      FilteredRankingListInputData input);
}
