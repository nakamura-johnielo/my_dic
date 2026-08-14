import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/word_detail_load_key.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/word_detail_state.dart';
import 'package:my_dic/features/word_detail/internal/presentation/view_model/word_detail_view_model.dart';
import 'package:my_dic/features/word_detail/port/presentation_dependencies.dart';

final wordDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<WordDetailViewModel, WordDetailState, WordDetailLoadKey>(
        (ref, key) {
  final viewModel = WordDetailViewModel(
    ref.watch(wordDetailPresentationDependenciesProvider).reader,
  );
  unawaited(viewModel.initialize(key));
  return viewModel;
});
