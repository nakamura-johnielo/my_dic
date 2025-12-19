import 'package:my_dic/features/ranking/domain/usecase/locate_ranking_pagenation/locate_ranking_pagenation_output_data.dart';

abstract class ILocateRankingPagenationPresenter {
  void execute(LocateRankingPagenationOutputData input);
}
