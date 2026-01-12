import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/my_word/di/usecase_di.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_ui_model.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_view_model.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_status_view_model.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_status_state.dart';




final myWordViewModelProvider = StateNotifierProvider<MyWordViewModel, MyWordStateNew>((ref) {
  return MyWordViewModel(
    ref.read(loadMyWordUseCaseProvider),
    ref.read(registerMyWordUseCaseProvider),
    ref.read(handleWordRegistrationUseCaseProvider),
    ref.read(updateMyWordUseCaseProvider),
    ref.read(deleteMyWordUseCaseProvider),
  );
});

final myWordStatusViewModelProvider = StateNotifierProvider.family
    .autoDispose<MyWordStatusViewModel, MyWordStatusState, int>(
  (ref, wordId) {
    final watchUsecase = ref.watch(watchMyWordStatusUseCaseProvider);
    final updateUsecase = ref.watch(updateMyWordStatusUseCaseProvider);
    
    return MyWordStatusViewModel(
      wordId,
      watchUsecase,
      updateUsecase,
    );
  },
);

// MyWordをIDごとにStream監視するProvider
final myWordStreamProvider = StreamProvider.family.autoDispose<MyWord, int>(
  (ref, wordId) {
    final viewModel = ref.watch(myWordViewModelProvider.notifier);
    return viewModel.streamMyWordById(wordId);//TODO viewmodel usecase
  },
);

