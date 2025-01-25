import 'package:my_dic/_Business_Rule/Usecase/simple_load_rankings22/i_load_rankings_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/simple_load_rankings22/load_rankings_output_data.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';

class LoadRankingPresenterImpl22 implements ILoadRankingsPresenter {
  final RankingViewModel _rankingViewModel;
  LoadRankingPresenterImpl22(this._rankingViewModel);

  @override
  void execute(LoadRankingsOutputData input) {
    //_rankingViewModel.addItemsInTail(input.rankingList);
  }
}
