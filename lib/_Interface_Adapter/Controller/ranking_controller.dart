import 'dart:developer';

import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_input_data.dart';

class RankingController {
  final ILoadRankingsUseCase _loadRankingsInteractor;

  RankingController(this._loadRankingsInteractor);

  void loadNext(int page, int size) {
    log("load:${page}");
    LoadRankingsInputData input = LoadRankingsInputData(page, size);
    _loadRankingsInteractor.execute(input);
  }
}
