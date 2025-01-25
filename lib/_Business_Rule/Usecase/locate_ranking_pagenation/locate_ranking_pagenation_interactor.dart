import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/locate_ranking_pagenation/i_locate_ranking_pagenation_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/locate_ranking_pagenation/i_locate_ranking_pagenation_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/locate_ranking_pagenation/locate_ranking_pagenation_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/locate_ranking_pagenation/locate_ranking_pagenation_output_data.dart';

class LocateRankingPagenationInteractor
    implements ILocateRankingPagenationUseCase {
  ILocateRankingPagenationPresenter _locateRankingPagenationPresenterImpl;
  LocateRankingPagenationInteractor(this._locateRankingPagenationPresenterImpl);

  @override
  void execute(LocateRankingPagenationInputData input) {
    LocateRankingPagenationOutputData output =
        LocateRankingPagenationOutputData(input.pagenationFilter);
    _locateRankingPagenationPresenterImpl.execute(output);
  }
}
