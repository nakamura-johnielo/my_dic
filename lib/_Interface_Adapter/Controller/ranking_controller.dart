import 'dart:developer';

import 'package:my_dic/Constants/Enums/i_enum.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/i_add_filter_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/delete_filter_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/delete_filter_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/i_delete_filter_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_input_data.dart';

class RankingController {
  final ILoadRankingsUseCase _loadRankingsInteractor;
  final IAddFilterUseCase _addFilterInteractor;
  final IDeleteFilterUseCase _deleteFilterInteractor;

  RankingController(this._loadRankingsInteractor, this._addFilterInteractor,
      this._deleteFilterInteractor);

  void loadNext(int page, int size) {
    log("load:$page");
    LoadRankingsInputData input = LoadRankingsInputData(page, size);
    _loadRankingsInteractor.execute(input);
  }

  void addFilter(DisplayEnumMixin data, int page, int size) {
    /* AddFilterInputData input = AddFilterInputData(data, page);
    _addFilterInteractor.execute(input); */
  }

  void deleteFilter(DisplayEnumMixin data) {
    DeleteFilterInputData input = DeleteFilterInputData(data);
    _deleteFilterInteractor.execute(input);
  }
}
