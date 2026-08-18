import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/port/command.dart';
import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_event.dart';
import 'package:my_dic/core/session/session_scope_key.dart';

abstract class _MyWordCommandBase extends StateNotifier<MyWordCommandState>
    implements UiEffectConsumer {
  _MyWordCommandBase() : super(const MyWordCommandState());

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

  void begin(String operation) {
    state = state.copyWith(command: CommandState.submitting(operation));
  }

  void succeed(String operation) {
    state = MyWordCommandState(
      command: CommandState.succeeded(operation),
      pendingEffect: UiEffectEnvelope(
        id: '$operation-${++_effectSequence}',
        effect: operation == 'update'
            ? const UiNoticeEffect('Word updated.')
            : const UiCloseDialogEffect(),
      ),
    );
  }

  void fail(String operation, AppError error) {
    AppLogger.print('My Word $operation failed: ${error.message}');
    state = MyWordCommandState(
      command: CommandState.failed(operation, error),
      pendingEffect: UiEffectEnvelope(
        id: '$operation-${++_effectSequence}',
        effect: UiNoticeEffect(AppErrorMessage.from(error).text),
      ),
    );
  }
}

class MyWordRegistrationCommand extends _MyWordCommandBase {
  MyWordRegistrationCommand(this._commands, this._scope);

  final MyWordCommandPort _commands;
  final SessionScopeKey _scope;

  Future<void> registerWord({
    required String headword,
    required String description,
  }) async {
    if (isSubmitting) return;
    const operation = 'register';
    begin(operation);
    final result = await _commands.register(RegisterMyWordCommand(
        headword: headword,
        description: description,
        accountScope: _scope.accountScope));
    result.when(
      success: (_) => succeed(operation),
      failure: (error) => fail(operation, error),
    );
  }
}

class MyWordCommand extends _MyWordCommandBase {
  MyWordCommand(this._wordId, this._commands, this._scope);

  final String _wordId;
  final MyWordCommandPort _commands;
  final SessionScopeKey _scope;

  // Future<void> registerWord({
  //   required String headword,
  //   required String description,
  // }) async {
  //   if (isSubmitting) return;
  //   const operation = 'register';
  //   begin(operation);
  //   final result = await _commands.register(RegisterMyWordCommand(
  //       headword: headword,
  //       description: description,
  //       accountScope: _scope.accountScope));
  //   result.when(
  //     success: (_) => succeed(operation),
  //     failure: (error) => fail(operation, error),
  //   );
  // }

  Future<void> deleteWord() async {
    if (isSubmitting) return;
    const operation = 'delete';
    begin(operation);
    final result = await _commands.delete(DeleteMyWordCommand(
        myWordId: _wordId, accountScope: _scope.accountScope));
    result.when(
      success: (_) => succeed(operation),
      failure: (error) => fail(operation, error),
    );
  }

  Future<void> updateWord({
    required String headword,
    required String description,
  }) async {
    if (isSubmitting) return;
    const operation = 'update';
    begin(operation);
    final result = await _commands.update(UpdateMyWordCommand(
        myWordId: _wordId,
        headword: headword,
        description: description,
        accountScope: _scope.accountScope));
    result.when(
      success: (_) => succeed(operation),
      failure: (error) => fail(operation, error),
    );
  }
}
