import 'dart:developer';

import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/i_update_ranking_filter_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/update_ranking_filter_output_data.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';

class UpdateRankingFilterPresenterImpl
    implements IUpdateRankingFilterPresenter {
  final RankingViewModel _rankingViewModel;
  UpdateRankingFilterPresenterImpl(this._rankingViewModel);

  @override
  void addFeatureTagFilter(AddFeatureTagFilterOutputData input) {
    _resetPage();
    _rankingViewModel.addFeatureTagFilter(input.data);
  }

  @override
  void addPartOfSpeechFilter(AddPartOfSpeechFilterOutputData input) {
    _resetPage();
    _rankingViewModel.addPartOfSpeechFilter(input.data);
  }

  @override
  void deleteFeatureTagFilter(DeleteFeatureTagFilterOutputData input) {
    _resetPage();
    _rankingViewModel.deleteFeatureTagFilter(input.data);
  }

  @override
  void deletePartOfSpeechFilter(DeletePartOfSpeechFilterOutputData input) {
    _resetPage();
    _rankingViewModel.deletePartOfSpeechFilter(input.data);
  }

  void _resetPage() {
    log("updatefilter in presenter");
    _rankingViewModel.page = 0;
  }
}
