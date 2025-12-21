import 'package:my_dic/features/ranking/domain/usecase/locate_ranking_pagenation/i_locate_ranking_pagenation_presenter.dart';
import 'package:my_dic/features/ranking/domain/usecase/locate_ranking_pagenation/i_locate_ranking_pagenation_use_case.dart';
import 'package:my_dic/features/ranking/domain/usecase/locate_ranking_pagenation/locate_ranking_pagenation_input_data.dart';
import 'package:my_dic/features/ranking/domain/usecase/locate_ranking_pagenation/locate_ranking_pagenation_output_data.dart';

class LocateRankingPagenationInteractor
    implements ILocateRankingPagenationUseCase {
  // final ILocateRankingPagenationPresenter _locateRankingPagenationPresenterImpl;
  LocateRankingPagenationInteractor();

  @override
  void execute(LocateRankingPagenationInputData input) {
    LocateRankingPagenationOutputData output =
        LocateRankingPagenationOutputData(input.pagenationFilter);
    //_locateRankingPagenationPresenterImpl.execute(output);
  }
}
