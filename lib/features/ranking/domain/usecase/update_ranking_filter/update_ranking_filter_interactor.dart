import 'package:my_dic/core/shared/enums/i_enum.dart';
import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/update_ranking_filter_input_data.dart';
import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/update_ranking_filter_output_data.dart';



class UpdateRankingFilterInteractor implements IUpdateRankingFilterUseCase {
  // final IUpdateRankingFilterPresenter _filterPresenterImpl;//TODO delete
  UpdateRankingFilterInteractor();

  @override
  UpdateRankingFilterOutputData execute(UpdateRankingFilterInputData input) {
    DisplayEnumMixin data = input.data;
    int filterType = input.filterType;

        return UpdateRankingFilterOutputData(data, filterType);
    // if (data is PartOfSpeech) {
    //   //log("updatefilter: ${data.display}");
    //   //filter type
    //   if (filterType != 0) {
    //     // add or delete
    //     AddPartOfSpeechFilterOutputData filterInput =
    //         AddPartOfSpeechFilterOutputData(data, filterType);
    //     _filterPresenterImpl.setPartOfSpeechFilter(filterInput);
    //     return UpdateRankingFilterOutputData(data, filterType);
    //   }
    //   /* if (filterType == -1) {
    //     // add or delete
    //     AddPartOfSpeechFilterOutputData filterInput =
    //         AddPartOfSpeechFilterOutputData(data);
    //     _filterPresenterImpl.setPartOfSpeechFilter(filterInput);
    //     return;
    //   } */
    //   DeletePartOfSpeechFilterOutputData filterInput =
    //       DeletePartOfSpeechFilterOutputData(data, filterType);
    //   _filterPresenterImpl.deletePartOfSpeechFilter(filterInput);
    // }

    // if (data is FeatureTag) {
    //   //filter type
    //   if (filterType != 0) {
    //     // add or delete
    //     AddFeatureTagFilterOutputData filterInput =
    //         AddFeatureTagFilterOutputData(data, filterType);
    //     _filterPresenterImpl.setFeatureTagFilter(filterInput);
    //     return;
    //   }
    //   /* if (filterType == -1) {
    //     // add or delete
    //     AddFeatureTagFilterOutputData filterInput =
    //         AddFeatureTagFilterOutputData(data);
    //     _filterPresenterImpl.setFeatureTagFilter(filterInput);
    //     return;
    //   } */
    //   DeleteFeatureTagFilterOutputData filterInput =
    //       DeleteFeatureTagFilterOutputData(data, filterType);
    //   _filterPresenterImpl.deleteFeatureTagFilter(filterInput);
    // }
  }
}
