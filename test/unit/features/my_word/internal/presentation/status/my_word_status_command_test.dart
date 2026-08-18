import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/internal/presentation/status/my_word_status_command.dart';
import 'package:my_dic/features/my_word/port/my_word.dart';

class _Commands extends Mock implements MyWordStatusCommandPort {}

void main() {
  setUpAll(() => registerFallbackValue(
      UpdateMyWordStatusCommand(myWordId: 'word', accountScope: 'a')));

  test('aggregate lane dedupes cross-operation taps and fences dispose',
      () async {
    final commands = _Commands();
    final completer = Completer<Result<void>>();
    when(() => commands.updateStatus(any())).thenAnswer((_) => completer.future);
    final command = MyWordStatusCommand(
        'word', commands, const SessionScopeKey(accountScope: 'a', epoch: 1));
    final states = <MyWordStatusCommandState>[];
    command.addListener(states.add);

    final first = command.toggleBookmark(false);
    await command.toggleLearned(false);
    verify(() => commands.updateStatus(any())).called(1);
    expect(command.state.command, isA<CommandSubmitting>());
    command.dispose();
    completer.complete(const Result.success(null));
    await first;
    expect(states.last.command, isA<CommandSubmitting>());
  });

  test('effects are owner-consumed LIFO and reject stale consumption',
      () async {
    final commands = _Commands();
    when(() => commands.updateStatus(any()))
        .thenAnswer((_) async => const Result.success(null));
    final command = MyWordStatusCommand(
        'word', commands, const SessionScopeKey(accountScope: 'a', epoch: 4));
    await command.toggleBookmark(false);
    final first = command.pendingEffect!;
    await command.toggleLearned(false);
    final second = command.pendingEffect!;
    expect(second.id, isNot(first.id));
    command.consumeEffect(first.id);
    expect(command.pendingEffect!.id, second.id);
    command.consumeEffect(second.id);
    expect(command.pendingEffect!.id, first.id);
    command.consumeEffect(first.id);
    expect(command.pendingEffect, isNull);
  });
}
