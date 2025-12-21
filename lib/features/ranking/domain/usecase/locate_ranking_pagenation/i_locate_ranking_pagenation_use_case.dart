import 'package:my_dic/features/ranking/domain/usecase/locate_ranking_pagenation/locate_ranking_pagenation_input_data.dart';

abstract class ILocateRankingPagenationUseCase {
  void execute(LocateRankingPagenationInputData input);
}
