import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

final class DictionaryWordStatusCommandState {
  const DictionaryWordStatusCommandState({
    this.command = const CommandState.idle(),
    this.effects = const [],
  });
  final CommandState command;
  final List<UiEffectEnvelope<UiEffect>> effects;
  UiEffectEnvelope<UiEffect>? get pendingEffect =>
      effects.isEmpty ? null : effects.last;
  bool get isSubmitting => command.isSubmitting;
  DictionaryWordStatusCommandState copyWith({bool clearEffect = false}) =>
      DictionaryWordStatusCommandState(
        command: command,
        effects: clearEffect ? effects.sublist(0, effects.length - 1) : effects,
      );
  DictionaryWordStatusCommandState withResult(
          CommandState command, UiEffectEnvelope<UiEffect> effect) =>
      DictionaryWordStatusCommandState(
        command: command,
        effects: [...effects, effect],
      );
}

/// エントリごとに 1 つの集約単一実行レーンを設けます。ブックマーク、学習済み、メモが
/// 同じステータスドキュメントへ競合して書き込むことはありません。
final class DictionaryWordStatusCommand
    extends StateNotifier<DictionaryWordStatusCommandState>
    implements UiEffectConsumer {
  DictionaryWordStatusCommand(this._word, this._commands, this._scope)
      : super(const DictionaryWordStatusCommandState());
  final CatalogWordRef _word;
  final WordStatusCommandPort _commands;
  final SessionScopeKey _scope;
  int _sequence = 0;
  bool get isSubmitting => state.isSubmitting;

  @override
  UiEffectEnvelope<UiEffect>? get pendingEffect => state.pendingEffect;
  @override
  void consumeEffect(String id) {
    if (shouldConsumeEffect(pendingEffect: pendingEffect, id: id)) {
      state = state.copyWith(clearEffect: true);
    }
  }

  Future<void> toggleBookmark(bool current) =>
      _update('toggleBookmark', isBookmarked: FieldUpdate.set(!current));
  Future<void> toggleLearned(bool current) =>
      _update('toggleLearned', isLearned: FieldUpdate.set(!current));
  Future<void> toggleHasNote(bool current) =>
      _update('toggleHasNote', hasNote: FieldUpdate.set(!current));

  Future<void> _update(
    String operation, {
    FieldUpdate<bool> isLearned = const FieldUpdate.unchanged(),
    FieldUpdate<bool> isBookmarked = const FieldUpdate.unchanged(),
    FieldUpdate<bool> hasNote = const FieldUpdate.unchanged(),
  }) async {
    if (state.isSubmitting) return;
    final expectedScope = _scope;
    state = DictionaryWordStatusCommandState(
      command: CommandState.submitting(operation),
      effects: state.effects,
    );
    final result = await _commands.update(
        UpdateWordStatusCommand(
            scope: expectedScope.accountScope == guestAccountScope
                ? const WordStatusScope.guest()
                : WordStatusScope.account(expectedScope.accountScope),
            word: _word,
            isLearned: isLearned,
            isBookmarked: isBookmarked,
            hasNote: hasNote));
    if (!mounted || expectedScope != _scope) return;
    final id = 'dictionary-word-status:${expectedScope.epoch}:${++_sequence}';
    state = result.isSuccess
        ? state.withResult(CommandState.succeeded(operation),
            UiEffectEnvelope(id: id, effect: const UiNoticeEffect('Saved.')))
        : state.withResult(
            CommandState.failed(operation, result.errorOrNull!),
            UiEffectEnvelope(
                id: id,
                effect: UiNoticeEffect(
                    AppErrorMessage.from(result.errorOrNull!).text)));
  }
}
