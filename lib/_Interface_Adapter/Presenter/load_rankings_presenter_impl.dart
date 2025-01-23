import 'dart:developer';

import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_output_data.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';

class LoadRankingsPresenterImpl implements ILoadRankingsPresenter {
  final RankingViewModel _rankingViewModel;
  LoadRankingsPresenterImpl(this._rankingViewModel);

  @override
  void execute(LoadRankingsOutputData input) {
    if (input.requiredPage == 0) {
      _resetItems();
    }
    log("page: ${_rankingViewModel.currentPage}");
    log("itemlength: ${_rankingViewModel.items.length}");
    _rankingViewModel.addItems(input.items);
  }

  void _resetItems() {
    //_rankingViewModel.items.clear();
    _rankingViewModel.items = [];
  }
}
