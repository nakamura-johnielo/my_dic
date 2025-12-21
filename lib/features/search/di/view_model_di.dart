import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/search/di/usecase_di.dart';
import 'package:my_dic/features/search/presentation/ui_model/search_ui_model.dart';
import 'package:my_dic/features/search/presentation/view_model/viewmodel.dart';
// import 'package:my_dic/features/search/presentation/view_model/search_view_model.dart';



final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  // final searchUsecase=
  return SearchViewModel(ref.read(searchWordUseCaseProvider),
      ref.read(judgeSearchWordUseCaseProvider));
});


