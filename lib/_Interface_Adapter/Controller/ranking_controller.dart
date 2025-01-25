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

  RankingController(
      //this._loadRankingsInteractor,
      /* this._addFilterInteractor,
      this._deleteFilterInteractor, */
      this._rankingViewModel,
      this._loadRankingsInteractor,
      this._updateRankingFilterInteractor,
      this._locateRankingPagenationInteractor);

  void locatePage(int page) {
    LocateRankingPagenationInputData input =
        LocateRankingPagenationInputData(page);
    _locateRankingPagenationInteractor.execute(input);
    _loadItemsByFilters();
  }

  void loadNext() {
    //log("load:${input.currentPage}");
    /* LoadRankingsInputData input = LoadRankingsInputData(page, size);
    _loadRankingsInteractor.execute(input); */
    /* LoadRankingsInputData inputLoadItems = LoadRankingsInputData(
        input.partOfSpeechFilters,
        input.featureTagFilters,
        input.currentPage,
        input.size);
    _loadRankingsInteractor.execute(inputLoadItems); */
    _loadItemsByFilters();
  }

  void loadPrevious(/* LoadRankingsControllerInputData input */) {
    //log("load:${input.currentPage}");
    /* LoadRankingsInputData input = LoadRankingsInputData(page, size);
    _loadRankingsInteractor.execute(input); */
    /*  LoadRankingsInputData inputLoadItems = LoadRankingsInputData(
        input.partOfSpeechFilters,
        input.featureTagFilters,
        input.currentPage,
        input.size);
    _loadRankingsInteractor.execute(inputLoadItems); */
    _loadItemsByFilters(isNext: false);
  }

  void addFilter(DisplayEnumMixin data) {
    bool isAdd = true;
    _updateFilter(data, isAdd); //データ取得しなおすから始めから presenter内でpage=0もセット済み
    _loadItemsByFilters();
  }

  void deleteFilter(DisplayEnumMixin data) {
    bool isAdd = false;
    _updateFilter(data, isAdd); //データ取得しなおすから始めから presenter内でpage=0もセット済み
    _loadItemsByFilters();
    /* DeleteFilterInputData input = DeleteFilterInputData(data);
    _deleteFilterInteractor.execute(input); */
  }

  void _loadItemsByFilters({bool isNext = true}) {
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

    _loadRankingsInteractor.execute(inputLoadItems);
  }

  void _updateFilter(DisplayEnumMixin data, bool isAdd) {
    //viewmodel.page=[-1,-1];をセット
    UpdateRankingFilterInputData input =
        UpdateRankingFilterInputData(data, isAdd);
    _updateRankingFilterInteractor.execute(input);

    /* LoadRankingsInputData inputLoadItems = LoadRankingsInputData(
        loadInput.partOfSpeechFilters,
        loadInput.featureTagFilters,
        loadInput.currentPage,
        loadInput.size);
    _loadRankingsInteractor.execute(inputLoadItems); */
  }
}
