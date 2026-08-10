import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/search/port/presentation_dependencies.dart';
import 'package:my_dic/features/search/internal/presentation/ui_model/search_ui_model.dart';
import 'package:my_dic/features/search/internal/presentation/view_model/viewmodel.dart';

final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  return SearchViewModel(ref.read(searchReaderPortDependencyProvider));
});
