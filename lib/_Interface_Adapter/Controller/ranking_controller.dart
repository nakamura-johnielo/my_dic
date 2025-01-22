import 'dart:developer';

import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/Constants/Enums/i_enum.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/i_add_filter_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/delete_filter_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/delete_filter_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/i_delete_filter_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/set_ranking_items/set_ranking_items_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/set_ranking_items/i_set_ranking_items_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/update_ranking_filter_input_data.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';

class RankingController {
  final ILoadRankingsUseCase _loadRankingsInteractor;
  //final IAddFilterUseCase _addFilterInteractor;
  //final IDeleteFilterUseCase _deleteFilterInteractor;
  final ISetRankingItemsUseCase _setRankingItemsInteractor;
  final IUpdateRankingFilterUseCase _updateRankingFilterInteractor;
  final RankingViewModel _rankingViewModel;

  RankingController(
      this._loadRankingsInteractor,
      /* this._addFilterInteractor,
      this._deleteFilterInteractor, */
      this._rankingViewModel,
      this._setRankingItemsInteractor,
      this._updateRankingFilterInteractor);

  void loadNext(int page, int size) {
    log("load:$page");
    /* LoadRankingsInputData input = LoadRankingsInputData(page, size);
    _loadRankingsInteractor.execute(input); */
    _setItemsByFilters();
  }

  void addFilter(DisplayEnumMixin data) {
    bool isAdd = true;
    _updateFilter(data, isAdd); //データ取得しなおすから始めから presenter内でpage=0もセット済み
    _setItemsByFilters();
  }

  void deleteFilter(DisplayEnumMixin data) {
    bool isAdd = false;
    _updateFilter(data, isAdd); //データ取得しなおすから始めから presenter内でpage=0もセット済み
    _setItemsByFilters();
    /* DeleteFilterInputData input = DeleteFilterInputData(data);
    _deleteFilterInteractor.execute(input); */
  }

  void _setItemsByFilters() {
    SetRankingItemsInputData inputGetItems = SetRankingItemsInputData(
        _rankingViewModel.partOfSpeechFilters,
        _rankingViewModel.featureTagFilters,
        _rankingViewModel.page,
        _rankingViewModel.size);

    _setRankingItemsInteractor.execute(inputGetItems);
  }

  void _updateFilter(DisplayEnumMixin data, bool isAdd) {
    UpdateRankingFilterInputData input =
        UpdateRankingFilterInputData(data, isAdd);
    _updateRankingFilterInteractor.execute(input);
  }
}
