import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Components/word_status_state.dart';
import 'package:my_dic/core/application/viewmodel/status_buttons_view_model.dart';
import 'package:my_dic/core/di/usecase/usecase_di.dart';

// final espJpnWordStatusViewModelProvider =
//     StateNotifierProvider<EspJpnWordStatusViewModel, WordStatusState>((ref) {
//   final fetchUsecase = ref.read(fetchEspJpnWordStatusInteractorProvider);
//   final updateUsecase = ref.read(updateStatusUseCaseProvider);
//   return EspJpnWordStatusViewModel(fetchUsecase, updateUsecase);
// });

final espJpnWordStatusViewModelProvider = StateNotifierProvider.family
    .autoDispose<EspJpnWordStatusViewModel, WordStatusState, int>(
  (ref, wordId) {
    final fetchUsecase = ref.watch(fetchEspJpnWordStatusInteractorProvider);
    final updateUsecase = ref.watch(updateStatusUseCaseProvider);
    
    return EspJpnWordStatusViewModel(
      wordId,
      fetchUsecase,
      updateUsecase,
    );
  },
);