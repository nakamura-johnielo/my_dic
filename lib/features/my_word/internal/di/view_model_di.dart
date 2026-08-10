import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/my_word/internal/application/query/my_word_item_projection.dart';
import 'package:my_dic/features/my_word/internal/di/data_di.dart';
import 'package:my_dic/features/my_word/internal/di/usecase_di.dart';
import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_event.dart';
import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_status_command_event.dart';
import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_ui_model.dart';
import 'package:my_dic/features/my_word/internal/presentation/view_model/my_word_command.dart';
import 'package:my_dic/features/my_word/internal/presentation/view_model/my_word_status_command.dart';
import 'package:my_dic/features/my_word/internal/presentation/view_model/my_word_view_model.dart';

final myWordFragmentViewModelProvider = StateNotifierProvider.autoDispose
    .family<MyWordFragmentViewModel, MyWordFragmentState, SessionScopeKey>(
        (ref, scope) {
  return MyWordFragmentViewModel(
    ref.read(loadMyWordUseCaseProvider),
    ref.read(registerMyWordUseCaseProvider),
    scope,
  );
});

/// Read-only combined word/status projection for a card. Commands remain on
/// their existing providers so the two write aggregates stay independent.
final myWordItemProjectionStreamProvider = StreamProvider.family.autoDispose<
    MyWordItemProjection?, ({SessionScopeKey scope, String wordId})>(
  (ref, key) {
    return ref
        .watch(myWordItemQueryRepositoryProvider)
        .watchItem(key.wordId, accountId: key.scope.accountScope);
  },
);

/// Presentation-only data derived from the one card read projection.
final myWordItemUiModelProvider = Provider.autoDispose.family<
    AsyncValue<MyWordItemUiModel?>,
    ({SessionScopeKey scope, String wordId})>((ref, key) {
  return ref.watch(myWordItemProjectionStreamProvider(key)).whenData(
        (projection) => projection == null
            ? null
            : MyWordItemUiModel.fromProjection(projection),
      );
});

// command

final myWordStatusCommandProvider = StateNotifierProvider.family.autoDispose<
    MyWordStatusCommand,
    MyWordStatusCommandState,
    ({SessionScopeKey scope, String wordId})>(
  (ref, key) {
    final updateUsecase = ref.read(updateMyWordStatusUseCaseProvider);

    return MyWordStatusCommand(key.wordId, updateUsecase, key.scope);
  },
);

final myWordCommandProvider = StateNotifierProvider.family.autoDispose<
    MyWordCommand,
    MyWordCommandState,
    ({SessionScopeKey scope, String wordId})>(
  (ref, key) {
    final updateUsecase = ref.read(updateMyWordUseCaseProvider);
    final deleteUsecase = ref.read(deleteMyWordUseCaseProvider);

    return MyWordCommand(key.wordId, updateUsecase, deleteUsecase, key.scope);
  },
);

final myWordRegistrationCommandProvider = StateNotifierProvider.autoDispose
    .family<MyWordRegistrationCommand, MyWordCommandState, SessionScopeKey>(
        (ref, scope) {
  return MyWordRegistrationCommand(
      ref.read(registerMyWordUseCaseProvider), scope);
});
