import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/usecase/usecase_di.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/jpn_esp_state.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/word_page_load_key.dart';
import 'package:my_dic/features/word_page/presentation/view_model/word_page_view_model.dart';
import 'package:my_dic/router/navigator_service.dart';

final wordPageViewModelProvider = StateNotifierProvider.autoDispose
    .family<WordPageViewModel, WordPageState, WordPageLoadKey>((ref, key) {
  final fetchJpnEspDictionaryInteractor =
      ref.read(fetchJpnEspDictionaryUseCaseProvider);
  final fetchEspJpnDictionaryInteractor =
      ref.read(fetchEspJpnDictionaryUseCaseProvider);
  final fetchEspConjugationInteractor =
      ref.read(fetchEspConjugationUseCaseProvider);
  final naviService = ref.read(appNavigatorServiceProvider);
  final viewModel = WordPageViewModel(
    fetchJpnEspDictionaryInteractor,
    fetchEspJpnDictionaryInteractor,
    fetchEspConjugationInteractor,
    naviService,
  );
  unawaited(viewModel.initialize(key));
  return viewModel;
});
