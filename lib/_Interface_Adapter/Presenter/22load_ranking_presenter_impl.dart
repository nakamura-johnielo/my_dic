import 'package:my_dic/_Business_Rule/Usecase/simple_load_rankings22/i_load_rankings_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/simple_load_rankings22/load_rankings_output_data.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';

class LoadRankingPresenterImpl implements ILoadRankingsPresenter {
  final RankingViewModel _rankingViewModel;
  LoadRankingPresenterImpl(this._rankingViewModel);

  @override
  void execute(LoadRankingsOutputData input) {
    _rankingViewModel.addItems(input.rankingList);
  }
}
