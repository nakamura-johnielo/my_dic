import 'dart:developer';

import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/Constants/Enums/i_enum.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';
/* import 'package:my_dic/Constants/Enums/part_of_speech.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/i_add_filter_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/delete_filter_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/delete_filter_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/i_delete_filter_use_case.dart'; */
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/locate_ranking_pagenation/i_locate_ranking_pagenation_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/locate_ranking_pagenation/locate_ranking_pagenation_input_data.dart';
/* import 'package:my_dic/_Business_Rule/Usecase/load_rankings22/i_load_rankings_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings22/load_rankings_input_data.dart'; */
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/update_ranking_filter_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_status/update_status_input_data.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';

class LoadRankingsControllerInputData {
  int currentPage;
  int size;
  Set<PartOfSpeech> partOfSpeechFilters;
  Set<FeatureTag> featureTagFilters;

  LoadRankingsControllerInputData(this.partOfSpeechFilters,
      this.featureTagFilters, this.currentPage, this.size);
}

class RankingController {
  //final ILoadRankingsUseCase _loadRankingsInteractor;
  //final IAddFilterUseCase _addFilterInteractor;
  //final IDeleteFilterUseCase _deleteFilterInteractor;
  final ILoadRankingsUseCase _loadRankingsInteractor;
  final IUpdateRankingFilterUseCase _updateRankingFilterInteractor;
  final ILocateRankingPagenationUseCase _locateRankingPagenationInteractor;
  final RankingViewModel _rankingViewModel;
  final IUpdateStatusUseCase _updateStatusInteractor;

  RankingController(
      this._rankingViewModel,
      this._loadRankingsInteractor,
      this._updateRankingFilterInteractor,
      this._locateRankingPagenationInteractor,
      this._updateStatusInteractor);

  void locatePage(int page) {
    LocateRankingPagenationInputData input =
        LocateRankingPagenationInputData(page);
    _locateRankingPagenationInteractor.execute(input);
    _loadItemsByFilters();
  }

  Future<void> loadNext() async {
    await _loadItemsByFilters();
    //return true;
  }

  Future<void> loadPrevious() async {
    await _loadItemsByFilters(isNext: false);
  }

  // void updateWordStatus(
  //   int index,
  //   int wordId,
  //   bool isBookmarked,
  //   bool isLearned,
  //   bool hasNote,
  // ) {
  //   log("updatecontroller");

  //   Set<FeatureTag> status = {
  //     if (isBookmarked) FeatureTag.isBookmarked,
  //     if (isLearned) FeatureTag.isLearned,
  //     if (hasNote) FeatureTag.hasNote,
  //   };
  //   UpdateStatusInputData input = UpdateStatusInputData(wordId, status, index);
  //   _updateStatusInteractor.execute(input);
  // }

  void addFilter(DisplayEnumMixin data, int filterType) {
    _updateFilter(data, filterType); //データ取得しなおすから始めから presenter内でpage=0もセット済み
    _loadItemsByFilters();
  }

  void deleteFilter(DisplayEnumMixin data, int filterType) {
    filterType = 0;
    _updateFilter(data, filterType); //データ取得しなおすから始めから presenter内でpage=0もセット済み
    _loadItemsByFilters();
  }

  Future<void> _loadItemsByFilters({bool isNext = true}) async {
    if (isNext) {
      _rankingViewModel.isNextLoading = true;
    } else {
      _rankingViewModel.isPreLoading = true;
    }
    LoadRankingsInputData inputLoadItems = LoadRankingsInputData(
        _rankingViewModel.partOfSpeechFilters,
        _rankingViewModel.featureTagFilters,
        _rankingViewModel.currentPage,
        _rankingViewModel.size,
        isNext,
        _rankingViewModel.pagenationFilter);

    await _loadRankingsInteractor.execute(inputLoadItems);
  }

  void _updateFilter(DisplayEnumMixin data, int filterType) {
    //viewmodel.page=[-1,-1];をセット
    UpdateRankingFilterInputData input =
        UpdateRankingFilterInputData(data, filterType);
    _updateRankingFilterInteractor.execute(input);
  }
}
