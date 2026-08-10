import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word_status/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word_status/update_my_word_status/update_my_word_status_input_data.dart';

/// Immutable command state. Effects are retained LIFO until their owner
/// consumes each exact envelope id, so rebuilds cannot replay or lose one.
final class MyWordStatusCommandState {
  const MyWordStatusCommandState({
    this.command = const CommandState.idle(),
    this.effects = const [],
  });

  final CommandState command;
  final List<UiEffectEnvelope<UiEffect>> effects;
  UiEffectEnvelope<UiEffect>? get pendingEffect =>
      effects.isEmpty ? null : effects.last;
  bool get isSubmitting => command.isSubmitting;

  MyWordStatusCommandState copyWith({
    CommandState? command,
    UiEffectEnvelope<UiEffect>? appendEffect,
    bool clearEffect = false,
  }) =>
      MyWordStatusCommandState(
        command: command ?? this.command,
        effects: clearEffect
            ? effects.sublist(0, effects.length - 1)
            : appendEffect == null
                ? effects
                : [...effects, appendEffect],
      );
}

final class MyWordStatusCommand extends StateNotifier<MyWordStatusCommandState>
    implements UiEffectConsumer {
  MyWordStatusCommand(this._wordId, this._updateUsecase, this._scope)
      : super(const MyWordStatusCommandState());

  final String _wordId;
  final IUpdateMyWordStatusUseCase _updateUsecase;
  final SessionScopeKey _scope;
  int _sequence = 0;

  @override
  UiEffectEnvelope<UiEffect>? get pendingEffect => state.pendingEffect;

  @override
  void consumeEffect(String id) {
    if (shouldConsumeEffect(pendingEffect: state.pendingEffect, id: id)) {
      state = state.copyWith(clearEffect: true);
    }
  }

  Future<void> toggleBookmark(bool value) => _set(
        'toggleBookmark',
        UpdateMyWordStatusInputData(
            _wordId,
            const FieldUpdate.unchanged(),
            FieldUpdate.set(!value),
            const FieldUpdate.unchanged(),
            _scope.accountScope),
      );
  Future<void> toggleLearned(bool value) => _set(
        'toggleLearned',
        UpdateMyWordStatusInputData(
            _wordId,
            FieldUpdate.set(!value),
            const FieldUpdate.unchanged(),
            const FieldUpdate.unchanged(),
            _scope.accountScope),
      );

  Future<void> _set(String operation, UpdateMyWordStatusInputData input) async {
    // The aggregate lane is the card (scope, word), not an individual field.
    if (state.isSubmitting) return;
    final expectedScope = _scope;
    state = state.copyWith(command: CommandState.submitting(operation));
    final result = await _updateUsecase.execute(input);
    if (!mounted || expectedScope != _scope) return;
    if (result.isSuccess) {
      state = state.copyWith(
        command: CommandState.succeeded(operation),
        appendEffect: UiEffectEnvelope(
          id: 'my-word-status:${expectedScope.epoch}:${++_sequence}',
          effect: const UiReloadEffect(),
        ),
      );
    } else {
      final error = result.errorOrNull!;
      state = state.copyWith(
        command: CommandState.failed(operation, error),
        appendEffect: UiEffectEnvelope(
          id: 'my-word-status:${expectedScope.epoch}:${++_sequence}',
          effect: UiNoticeEffect(AppErrorMessage.from(error).text),
        ),
      );
    }
  }
}
