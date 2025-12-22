
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/usecase/usecase_di.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/jpn_esp_state.dart';
import 'package:my_dic/features/word_page/presentation/view_model/word_page_view_model.dart';

final wordPageViewModelProvider=
    StateNotifierProvider<WordPageViewModel, WordPageState>((ref) {
  final fetchJpnEspDictionaryInteractor = ref.read(fetchJpnEspDictionaryUseCaseProvider);
  final fetchEspJpnDictionaryInteractor = ref.read(fetchEspJpnDictionaryUseCaseProvider);
  final fetchEspConjugationInteractor =
      ref.read(fetchEspConjugationUseCaseProvider);
  return WordPageViewModel(
      fetchJpnEspDictionaryInteractor,
      fetchEspJpnDictionaryInteractor,
      fetchEspConjugationInteractor);
});


// IFetchJpnEspDictionaryUseCase
// IFetchEspJpnDictionaryUseCase
// IFetchEspConjugationUseCase