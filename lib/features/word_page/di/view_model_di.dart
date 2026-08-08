import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';
import 'package:my_dic/features/word_page/application/query/load_word_detail_query.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/jpn_esp_state.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/word_page_load_key.dart';
import 'package:my_dic/features/word_page/presentation/view_model/word_page_view_model.dart';

final wordPageViewModelProvider = StateNotifierProvider.autoDispose
    .family<WordPageViewModel, WordPageState, WordPageLoadKey>((ref, key) {
  final viewModel = WordPageViewModel(LoadWordDetailQuery(
    ref.read(catalogReaderProvider),
    ref.read(conjugationReaderProvider),
  ));
  unawaited(viewModel.initialize(key));
  return viewModel;
});
