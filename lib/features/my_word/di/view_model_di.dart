import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/my_word/di/usecase_di.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_event.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_status_command_event.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_ui_model.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_command.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_status_command.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_view_model.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_status_state.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_item_view_model.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_status_view_model.dart';

final myWordFragmentViewModelProvider =
    StateNotifierProvider<MyWordFragmentViewModel, MyWordFragmentState>((ref) {
  return MyWordFragmentViewModel(
    ref.read(loadMyWordUseCaseProvider),
    ref.read(registerMyWordUseCaseProvider),
    ref.read(handleWordRegistrationUseCaseProvider),
  );
});

// final myWordStatusViewModelProvider = StateNotifierProvider.family
//     .autoDispose<MyWordStatusViewModel, MyWordStatusState, int>(
//   (ref, wordId) {
//     final watchUsecase = ref.watch(watchMyWordStatusUseCaseProvider);
//     final updateUsecase = ref.watch(updateMyWordStatusUseCaseProvider);

//     return MyWordStatusViewModel(
//       wordId,
//       watchUsecase,
//       updateUsecase,
//     );
//   },
// );

// stream
final _myWordStatusStreamProvider =
    StreamProvider.family.autoDispose<MyWordStatus, int>(
  (ref, wordId) {
    final watchUsecase = ref.read(watchMyWordStatusUseCaseProvider);
    return watchUsecase.execute(wordId);
  },
);

final _myWordStreamProviderNEW = StreamProvider.family.autoDispose<MyWord, int>(
  (ref, wordId) {
    final watchUsecase = ref.read(watchMyWordUseCaseProvider);
    return watchUsecase.execute(wordId);
  },
);

// QUERY uistate
final myWordStatusUiStateProvider =
    Provider.autoDispose.family<MyWordStatusState, int>((ref, int wordId) {
  final statusAsync = ref.watch(_myWordStatusStreamProvider(wordId));

  return MyWordStatusState.fromAsync(statusAsync);
});

final myWordUiStateProvider =
    Provider.autoDispose.family<MyWordUiState, int>((ref, int wordId) {
  final statusAsync = ref.watch(_myWordStreamProviderNEW(wordId));

  return MyWordUiState.fromAsync(statusAsync);
});

// command

final myWordStatusCommandProvider = StateNotifierProvider.family
    .autoDispose<MyWordStatusCommand, MyWordStatusCommandEvent?, int>(
  (ref, wordId) {
    final updateUsecase = ref.read(updateMyWordStatusUseCaseProvider);

    return MyWordStatusCommand(wordId, updateUsecase);
  },
);

final myWordCommandProvider = StateNotifierProvider.family
    .autoDispose<MyWordCommand, MyWordCommandEvent?, int>(
  (ref, wordId) {
    final updateUsecase = ref.read(updateMyWordUseCaseProvider);
    final deleteUsecase = ref.read(deleteMyWordUseCaseProvider);

    return MyWordCommand(wordId, updateUsecase, deleteUsecase);
  },
);

// ViewModel (query + command wrapper)
final myWordStatusViewModelProvider =
    Provider.autoDispose.family<MyWordStatusViewModel, int>((ref, wordId) {
  final uiState = ref.watch(myWordStatusUiStateProvider(wordId));
  final command = ref.read(myWordStatusCommandProvider(wordId).notifier);

  return MyWordStatusViewModel(uiState, command);
});

final myWordItemViewModelProvider =
    Provider.autoDispose.family<MyWordItemViewModel, int>((ref, wordId) {
  final uiState = ref.watch(myWordUiStateProvider(wordId));
  final command = ref.read(myWordCommandProvider(wordId).notifier);

  return MyWordItemViewModel(uiState, command);
});
