import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/application/usecase/auth_usecases.dart';
import 'package:my_dic/features/auth/presentation/ui_model/sign_in_model.dart';

class SignInViewModel extends StateNotifier<SignInUIState>
    implements UiEffectConsumer {
  SignInViewModel(this._resetEmailPasswordUseCase)
      : super(const SignInUIState());

  final IResetEmailPasswordUseCase _resetEmailPasswordUseCase;
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
        action: () => _resetEmailPasswordUseCase.execute(email),
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
    result.when(
      success: (_) => state = SignInUIState(
        command: CommandState.succeeded(operation),
        pendingEffect: _notice(operation, successMessage),
      ),
      failure: (AppError error) => state = SignInUIState(
        command: CommandState.failed(operation, error),
        pendingEffect: _notice(operation, AppErrorMessage.from(error).text),
      ),
    );
  }

  UiEffectEnvelope<UiEffect> _notice(String operation, String message) =>
      UiEffectEnvelope(
        id: '$operation-${++_effectSequence}',
        effect: UiNoticeEffect(message),
      );
}
