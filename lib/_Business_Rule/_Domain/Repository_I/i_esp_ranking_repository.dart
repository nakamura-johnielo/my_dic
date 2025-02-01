import 'package:my_dic/_Business_Rule/Usecase/load_rankings/filtered_ranking_list_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';

abstract class IEspRankingRepository {
  Future<List<Ranking>> getRankingList(int page, int size);
  Future<List<Ranking>> getRankingListByFilters(
      FilteredRankingListInputData input);
}
