import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';

class MyWordCommandState {
  const MyWordCommandState({
    this.command = const CommandState.idle(),
    this.pendingEffect,
  });

  final CommandState command;
  final UiEffectEnvelope<UiEffect>? pendingEffect;

  MyWordCommandState copyWith({
    CommandState? command,
    UiEffectEnvelope<UiEffect>? pendingEffect,
    bool clearEffect = false,
  }) =>
      MyWordCommandState(
        command: command ?? this.command,
        pendingEffect: clearEffect ? null : pendingEffect ?? this.pendingEffect,
      );
}
