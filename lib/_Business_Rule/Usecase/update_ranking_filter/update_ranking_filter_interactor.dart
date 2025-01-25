import 'dart:developer';

import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/Constants/Enums/i_enum.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/i_update_ranking_filter_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/update_ranking_filter_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/update_ranking_filter_output_data.dart';

class UpdateRankingFilterInteractor implements IUpdateRankingFilterUseCase {
  final IUpdateRankingFilterPresenter _filterPresenterImpl;
  UpdateRankingFilterInteractor(this._filterPresenterImpl);

  @override
  void execute(UpdateRankingFilterInputData input) {
    DisplayEnumMixin data = input.data;
    bool isAdd = input.isAdd;

    if (data is PartOfSpeech) {
      //log("updatefilter: ${data.display}");
      //filter type
      if (isAdd) {
        // add or delete
        AddPartOfSpeechFilterOutputData filterInput =
            AddPartOfSpeechFilterOutputData(data);
        _filterPresenterImpl.addPartOfSpeechFilter(filterInput);
        return;
      }
      DeletePartOfSpeechFilterOutputData filterInput =
          DeletePartOfSpeechFilterOutputData(data);
      _filterPresenterImpl.deletePartOfSpeechFilter(filterInput);
    }

    if (data is FeatureTag) {
      //filter type
      if (isAdd) {
        // add or delete
        AddFeatureTagFilterOutputData filterInput =
            AddFeatureTagFilterOutputData(data);
        _filterPresenterImpl.addFeatureTagFilter(filterInput);
        return;
      }
      DeleteFeatureTagFilterOutputData filterInput =
          DeleteFeatureTagFilterOutputData(data);
      _filterPresenterImpl.deleteFeatureTagFilter(filterInput);
    }
  }
}
