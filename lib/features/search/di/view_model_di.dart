import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/search/di/usecase_di.dart';
import 'package:my_dic/features/search/presentation/ui_model/search_ui_model.dart';
import 'package:my_dic/features/search/presentation/view_model/viewmodel.dart';

final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  return SearchViewModel(ref.read(searchWordUseCaseProvider),
      ref.read(judgeSearchWordUseCaseProvider));
});
