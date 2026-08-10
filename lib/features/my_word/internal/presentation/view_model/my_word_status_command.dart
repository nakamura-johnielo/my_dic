import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word_status/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word_status/update_my_word_status/update_my_word_status_input_data.dart';
import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_status_command_event.dart';
import 'package:my_dic/core/session/session_scope_key.dart';

class MyWordStatusCommand extends StateNotifier<MyWordStatusCommandState>
    implements UiEffectConsumer {
  MyWordStatusCommand(this._wordId, this._updateUsecase, this._scope)
      : super(const MyWordStatusCommandState());

  final String _wordId;
  final IUpdateMyWordStatusUseCase _updateUsecase;
  final SessionScopeKey _scope;
  int _effectSequence = 0;

  @override
  UiEffectEnvelope<UiEffect>? get pendingEffect => state.pendingEffect;

  @override
  void consumeEffect(String id) {
    if (shouldConsumeEffect(pendingEffect: state.pendingEffect, id: id)) {
      state = state.copyWith(clearEffect: true);
    }
  }

  Future<void> toggleBookmark(bool value) => _set(
        operation: 'toggleBookmark',
        input: UpdateMyWordStatusInputData(
          _wordId,
          const FieldUpdate.unchanged(),
          FieldUpdate.set(!value),
          const FieldUpdate.unchanged(),
          _scope.accountScope,
        ),
      );

  Future<void> toggleLearned(bool value) => _set(
        operation: 'toggleLearned',
        input: UpdateMyWordStatusInputData(
          _wordId,
          FieldUpdate.set(!value),
          const FieldUpdate.unchanged(),
          const FieldUpdate.unchanged(),
          _scope.accountScope,
        ),
      );

  Future<void> _set({
    required String operation,
    required UpdateMyWordStatusInputData input,
  }) async {
    if (state.command.isSubmitting) return;
    state = state.copyWith(command: CommandState.submitting(operation));
    final result = await _updateUsecase.execute(input);
    result.when(
      success: (_) {
        state = MyWordStatusCommandState(
          command: CommandState.succeeded(operation),
          pendingEffect: UiEffectEnvelope(
            id: '$operation-${++_effectSequence}',
            effect: const UiReloadEffect(),
          ),
        );
      },
      failure: (AppError error) {
        state = MyWordStatusCommandState(
          command: CommandState.failed(operation, error),
          pendingEffect: UiEffectEnvelope(
            id: '$operation-${++_effectSequence}',
            effect: UiNoticeEffect(AppErrorMessage.from(error).text),
          ),
        );
      },
    );
  }
}
