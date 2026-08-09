import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/my_word/application/query/my_word_item_projection.dart';
import 'package:my_dic/features/my_word/di/data_di.dart';
import 'package:my_dic/features/my_word/di/usecase_di.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_event.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_status_command_event.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_ui_model.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_command.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_status_command.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_view_model.dart';

final myWordFragmentViewModelProvider =
    StateNotifierProvider<MyWordFragmentViewModel, MyWordFragmentState>((ref) {
  return MyWordFragmentViewModel(
    ref.read(loadMyWordUseCaseProvider),
    ref.read(registerMyWordUseCaseProvider),
  );
});

/// Read-only combined word/status projection for a card. Commands remain on
/// their existing providers so the two write aggregates stay independent.
final myWordItemProjectionStreamProvider =
    StreamProvider.family.autoDispose<MyWordItemProjection?, String>(
  (ref, wordId) {
    final accountId =
        ref.watch(currentSessionProvider).accountIdOrNull ?? guestAccountScope;
    return ref
        .watch(myWordItemQueryRepositoryProvider)
        .watchItem(wordId, accountId: accountId);
  },
);

/// Presentation-only data derived from the one card read projection.
final myWordItemUiModelProvider = Provider.autoDispose
    .family<AsyncValue<MyWordItemUiModel?>, String>((ref, wordId) {
  return ref.watch(myWordItemProjectionStreamProvider(wordId)).whenData(
        (projection) => projection == null
            ? null
            : MyWordItemUiModel.fromProjection(projection),
      );
});

// command

final myWordStatusCommandProvider = StateNotifierProvider.family
    .autoDispose<MyWordStatusCommand, MyWordStatusCommandState, String>(
  (ref, wordId) {
    final updateUsecase = ref.read(updateMyWordStatusUseCaseProvider);

    return MyWordStatusCommand(wordId, updateUsecase);
  },
);

final myWordCommandProvider = StateNotifierProvider.family
    .autoDispose<MyWordCommand, MyWordCommandState, String>(
  (ref, wordId) {
    final updateUsecase = ref.read(updateMyWordUseCaseProvider);
    final deleteUsecase = ref.read(deleteMyWordUseCaseProvider);

    return MyWordCommand(wordId, updateUsecase, deleteUsecase);
  },
);

final myWordRegistrationCommandProvider = StateNotifierProvider.autoDispose<
    MyWordRegistrationCommand, MyWordCommandState>((ref) {
  return MyWordRegistrationCommand(ref.read(registerMyWordUseCaseProvider));
});
