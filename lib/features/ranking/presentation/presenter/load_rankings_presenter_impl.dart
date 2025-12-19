import 'dart:developer';

import 'package:my_dic/features/ranking/domain/usecase/load_rankings/i_load_rankings_presenter.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/load_rankings_output_data.dart';
import 'package:my_dic/features/ranking/presentation/view_model/ranking_view_model.dart';

class LoadRankingsPresenterImpl implements ILoadRankingsPresenter {
  final RankingViewModel _rankingViewModel;
  LoadRankingsPresenterImpl(this._rankingViewModel);

  @override
  void execute(LoadRankingsOutputData input) {
    if (input.requiredPage == 0) {
      _resetItems();
    }
    /* log("page: ${_rankingViewModel.currentPage}");
    log("itemlength: ${_rankingViewModel.items.length}"); */
    //_rankingViewModel.addItemsInTail(input.items);
  }

  void _resetItems() {
    //_rankingViewModel.items.clear();
    //_rankingViewModel.items = [];
    _rankingViewModel.clearItems();
  }

  @override
  void handleNext(LoadRankingsOutputData input) {
    if (input.requiredPage[0] == input.requiredPage[1]) {
      _resetItems();
    }
    log("handleNext ");
    /* log("handleNext page: ${_rankingViewModel.currentPage}");
    log("itemlength: ${_rankingViewModel.items.length}");
    log("itemlength input: ${input.items.length}"); */
    _rankingViewModel.addItemsInTail(input.items, input.requiredPage);
  }

  @override
  void handlePrevious(LoadRankingsOutputData input) {
    if (input.requiredPage[0] == input.requiredPage[1]) {
      _resetItems();
    }
    log("handlePre ");
    /* log("page: ${_rankingViewModel.currentPage}");
    log("itemlength: ${_rankingViewModel.items.length}"); */
    _rankingViewModel.addItemsInHead(input.items, input.requiredPage);
  }
}
