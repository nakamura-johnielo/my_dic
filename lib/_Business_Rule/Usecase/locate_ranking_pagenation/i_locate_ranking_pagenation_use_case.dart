import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/locate_ranking_pagenation/locate_ranking_pagenation_input_data.dart';

abstract class ILocateRankingPagenationUseCase {
  void execute(LocateRankingPagenationInputData input);
}
