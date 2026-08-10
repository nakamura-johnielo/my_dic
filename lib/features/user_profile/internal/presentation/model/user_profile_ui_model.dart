import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';

class UserProfileUIState {
  const UserProfileUIState({
    this.command = const CommandState.idle(),
    this.pendingEffect,
  });

  final CommandState command;
  final UiEffectEnvelope<UiEffect>? pendingEffect;

  UserProfileUIState copyWith({
    CommandState? command,
    UiEffectEnvelope<UiEffect>? pendingEffect,
    bool clearEffect = false,
  }) =>
      UserProfileUIState(
        command: command ?? this.command,
        pendingEffect: clearEffect ? null : pendingEffect ?? this.pendingEffect,
      );
}
