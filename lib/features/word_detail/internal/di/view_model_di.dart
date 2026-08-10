import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/catalog/port/presentation_dependencies.dart';
import 'package:my_dic/features/word_detail/internal/application/query/load_word_detail_query.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/jpn_esp_state.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/word_detail_load_key.dart';
import 'package:my_dic/features/word_detail/internal/presentation/view_model/word_detail_view_model.dart';

final wordDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<WordDetailViewModel, WordDetailState, WordDetailLoadKey>((ref, key) {
  final viewModel = WordDetailViewModel(LoadWordDetailQuery(
    ref.read(catalogReaderPortDependencyProvider),
    ref.read(conjugationReaderPortDependencyProvider),
  ));
  unawaited(viewModel.initialize(key));
  return viewModel;
});
