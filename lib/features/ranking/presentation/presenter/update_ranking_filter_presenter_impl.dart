import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/i_update_ranking_filter_presenter.dart';
import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/update_ranking_filter_output_data.dart';
import 'package:my_dic/features/ranking/presentation/view_model/ranking_view_model.dart';

class UpdateRankingFilterPresenterImpl
    implements IUpdateRankingFilterPresenter {
  final RankingViewModel _rankingViewModel;
  UpdateRankingFilterPresenterImpl(this._rankingViewModel);

  @override
  void setFeatureTagFilter(AddFeatureTagFilterOutputData input) {
    _resetPage();
    _rankingViewModel.setFeatureTagFilter(input.data, input.filterType);
  }

  @override
  void setPartOfSpeechFilter(AddPartOfSpeechFilterOutputData input) {
    _resetPage();
    _rankingViewModel.setPartOfSpeechFilter(input.data, input.filterType);
  }

  @override
  void deleteFeatureTagFilter(DeleteFeatureTagFilterOutputData input) {
    _resetPage();
    _rankingViewModel.setFeatureTagFilter(input.data, input.filterType);
  }

  @override
  void deletePartOfSpeechFilter(DeletePartOfSpeechFilterOutputData input) {
    _resetPage();
    _rankingViewModel.setPartOfSpeechFilter(input.data, input.filterType);
  }

  void _resetPage() {
    //log("updatefilter in presenter");
    _rankingViewModel.resetCurrrentPage();
    _rankingViewModel.isOnUpdatedFilter = true;
    //_rankingViewModel.checkUpdateFilter();
  }
}
