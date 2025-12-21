import 'dart:developer';

import 'package:my_dic/features/ranking/domain/usecase/locate_ranking_pagenation/i_locate_ranking_pagenation_presenter.dart';
import 'package:my_dic/features/ranking/domain/usecase/locate_ranking_pagenation/locate_ranking_pagenation_output_data.dart';
import 'package:my_dic/features/ranking/presentation/view_model/ranking_view_model.dart';

class LocateRankingPagenationPresenterImpl
    implements ILocateRankingPagenationPresenter {
  final RankingViewModel _viewmodel;
  LocateRankingPagenationPresenterImpl(this._viewmodel);

  @override
  void execute(LocateRankingPagenationOutputData input) {
    _viewmodel.pagenationFilter = input.pagenationFilter;
    log("pagenationfilter: ${_viewmodel.pagenationFilter.toString()}");
    log("page: ${_viewmodel.currentPage}");
  }
}
