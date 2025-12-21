import 'package:my_dic/features/ranking/domain/usecase/load_rankings/filtered_ranking_list_input_data.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';

abstract class IEspRankingRepository {
  Future<List<Ranking>> getRankingList(int page, int size);
  Future<List<Ranking>> getRankingListByFilters(
      FilteredRankingListInputData input);
}
