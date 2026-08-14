import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/features/auth/internal/presentation/ui_model/sign_in_model.dart';
import 'package:my_dic/features/auth/port/auth.dart';

class SignInViewModel extends StateNotifier<SignInUIState>
    implements UiEffectConsumer {
  SignInViewModel(this._commands)
      : super(const SignInUIState());

  final AuthCommandPort _commands;
  int _effectSequence = 0;

  @override
  UiEffectEnvelope<UiEffect>? get pendingEffect => state.pendingEffect;

  @override
  void consumeEffect(String id) {
    if (shouldConsumeEffect(pendingEffect: state.pendingEffect, id: id)) {
      state = state.copyWith(clearEffect: true);
    }
  }

  bool get isSubmitting => state.command.isSubmitting;

  Future<void> resetEmailPassword(String email) => _run(
        operation: 'resetPassword',
        action: () => _commands.resetPassword(ResetPasswordCommand(email: email)),
        successMessage: 'Password reset email sent.',
      );

  Future<void> _run({
    required String operation,
    required Future<Result<void>> Function() action,
    required String successMessage,
  }) async {
    if (isSubmitting) return;
    state = state.copyWith(command: CommandState.submitting(operation));
    final result = await action();
    if (result is Success<void>) {
      state = SignInUIState(
        command: CommandState.succeeded(operation),
        pendingEffect: _notice(operation, successMessage),
      );
      return;
    }
    final error = result.errorOrNull!;
    state = SignInUIState(
      command: CommandState.failed(operation, error),
      pendingEffect: _notice(operation, AppErrorMessage.from(error).text),
    );
  }

  UiEffectEnvelope<UiEffect> _notice(String operation, String message) =>
      UiEffectEnvelope(
        id: '$operation-${++_effectSequence}',
        effect: UiNoticeEffect(message),
      );
}
