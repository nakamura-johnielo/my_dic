import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/set_ranking_items/filtered_ranking_list_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';

abstract class IEspRankingRepository {
  Future<List<Ranking>> getRankingList(int page, int size);
  Future<List<Ranking>> getRankingListByFilters(
      FilteredRankingListInputData input);
}
