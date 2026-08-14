import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/auth/subscription_status.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';
import 'package:my_dic/features/user_profile/internal/presentation/model/user_profile_ui_model.dart';

class UserProfileViewModel extends StateNotifier<UserProfileUIState>
    implements UiEffectConsumer {
  UserProfileViewModel(this._scope, this._updateUser)
      : super(const UserProfileUIState());

  final SessionScopeKey _scope;
  final UserProfileCommandPort _updateUser;
  int _effectSequence = 0;

  SessionScopeKey get scope => _scope;

  @override
  UiEffectEnvelope<UiEffect>? get pendingEffect => state.pendingEffect;

  @override
  void consumeEffect(String id) {
    if (shouldConsumeEffect(pendingEffect: state.pendingEffect, id: id)) {
      state = state.copyWith(clearEffect: true);
    }
  }

  bool get isSubmitting => state.command.isSubmitting;

  Future<void> save(
    AppUser currentProfile, {
    String? deviceId,
    String? email,
    String? username,
    SubscriptionStatus? subscriptionStatus,
  }) =>
      _run(
        operation: 'save',
        action: () => _updateUser.updateUser(
          currentProfile.copyWith(
            deviceId: deviceId,
            email: email,
            username: username,
            subscriptionStatus: subscriptionStatus,
          ),
          _scope.accountScope,
        ),
        successMessage: 'Profile saved.',
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
      success: (_) => state = UserProfileUIState(
        command: CommandState.succeeded(operation),
        pendingEffect: _notice(operation, successMessage),
      ),
      failure: (AppError error) => state = UserProfileUIState(
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
