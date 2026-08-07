import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/features/auth/auth_coordinator.dart';
import 'package:my_dic/features/user/presentation/model/user_profile_ui_model.dart';
import 'package:my_dic/features/user/user_coodinator.dart';

class UserProfileViewModel extends StateNotifier<UserProfileUIState>
    implements UiEffectConsumer {
  UserProfileViewModel(this._coordinator, this._authCoordinator)
      : super(const UserProfileUIState());

  final AppUserCoordinator _coordinator;
  final AppAuthCoordinator _authCoordinator;
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

  Future<void> signOut() => _run(
        operation: 'signOut',
        action: _authCoordinator.signOut,
        successMessage: 'Signed out.',
      );

  Future<void> save({String? email, String? username}) => _run(
        operation: 'save',
        action: () => _coordinator.updateUser(email: email, username: username),
        successMessage: 'Profile saved.',
      );

  Future<void> _run({
    required String operation,
    required Future<dynamic> Function() action,
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
