import 'dart:developer';

import 'package:my_dic/_Business_Rule/Usecase/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/my_word.dart';
import 'package:my_dic/_Interface_Adapter/Controller/infinity_scrollable_controller.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/infinity_scrollable_viewmodel.dart';
import 'package:path/path.dart';

class MyWordController extends InfinityScrollableController {
  final ILoadMyWordUseCase _loadMyWordInteractor;
  //final InfinityScrollableViewModel<MyWord> _viewModel;
  //MyWordController(this._loadMyWordInteractor, this._viewModel);
  MyWordController(this._loadMyWordInteractor);

  @override
  bool loadNext(int size, List<int> currentPage) {
    log("lodNext");
    //List<int> requiredPages = [_viewModel.currentPage[0], _viewModel.currentPage[1]];

    LoadMyWordInputData input = LoadMyWordInputData(size, currentPage[1]);
    _loadMyWordInteractor.execute(input);
    return true;
  }
}
