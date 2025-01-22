import 'dart:developer';

import 'package:my_dic/_Business_Rule/Usecase/set_ranking_items/i_set_ranking_items_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/set_ranking_items/set_ranking_items_output_data.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';

class SetRankingItemsPresenterImpl implements ISetRankingItemsPresenter {
  final RankingViewModel _rankingViewModel;
  SetRankingItemsPresenterImpl(this._rankingViewModel);

  @override
  void execute(SetRankingItemsOutputData input) {
    if (input.page == 0) {
      _resetItems();
    }
    log("page: ${_rankingViewModel.page}");
    log("itemlength: ${_rankingViewModel.items.length}");
    _rankingViewModel.addItems(input.items);
  }

  void _resetItems() {
    //_rankingViewModel.items.clear();
    _rankingViewModel.items = [];
  }
}
