import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_status/internal/application/update_word_status.dart';
import 'package:my_dic/features/word_status/internal/presentation/dictionary_status/dictionary_word_status_command.dart';
import 'package:my_dic/features/word_status/port/repository.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

class _Repository extends Mock implements WordStatusRepository {}

void main() {
  const scope = SessionScopeKey(accountScope: 'account', epoch: 7);
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 9);
  setUpAll(() {
    registerFallbackValue(word);
    registerFallbackValue(const FieldUpdate<bool>.unchanged());
  });

  test('dedupes bookmark/learned/note in one aggregate lane', () async {
    final repo = _Repository();
    final wait = Completer<Result<WordStatus>>();
    when(() => repo.update(word,
        isLearned: any(named: 'isLearned'),
        isBookmarked: any(named: 'isBookmarked'),
        hasNote: any(named: 'hasNote'),
        updatedAt: any(named: 'updatedAt'),
        accountId: any(named: 'accountId'))).thenAnswer((_) => wait.future);
    final command =
        DictionaryWordStatusCommand(word, UpdateWordStatus(repo), scope);
    final first = command.toggleBookmark(false);
    await command.toggleLearned(false);
    await command.toggleHasNote(false);
    verify(() => repo.update(word,
        isLearned: any(named: 'isLearned'),
        isBookmarked: any(named: 'isBookmarked'),
        hasNote: any(named: 'hasNote'),
        updatedAt: any(named: 'updatedAt'),
        accountId: 'account')).called(1);
    wait.complete(Result.success(_status()));
    await first;
  });

  test('publishes typed failure effect once and ignores stale consumption',
      () async {
    final repo = _Repository();
    when(() => repo.update(any(),
            isLearned: any(named: 'isLearned'),
            isBookmarked: any(named: 'isBookmarked'),
            hasNote: any(named: 'hasNote'),
            updatedAt: any(named: 'updatedAt'),
            accountId: any(named: 'accountId')))
        .thenAnswer(
            (_) async => Result.failure(DatabaseError(message: 'offline')));
    final command =
        DictionaryWordStatusCommand(word, UpdateWordStatus(repo), scope);
    await command.toggleLearned(false);
    expect(command.state.command, isA<CommandFailed>());
    final effect = command.pendingEffect!;
    command.consumeEffect('wrong-id');
    expect(command.pendingEffect!.id, effect.id);
    command.consumeEffect(effect.id);
    expect(command.pendingEffect, isNull);
  });

  test('does not publish after disposal late completion', () async {
    final repo = _Repository();
    final wait = Completer<Result<WordStatus>>();
    when(() => repo.update(any(),
        isLearned: any(named: 'isLearned'),
        isBookmarked: any(named: 'isBookmarked'),
        hasNote: any(named: 'hasNote'),
        updatedAt: any(named: 'updatedAt'),
        accountId: any(named: 'accountId'))).thenAnswer((_) => wait.future);
    final command =
        DictionaryWordStatusCommand(word, UpdateWordStatus(repo), scope);
    final states = <DictionaryWordStatusCommandState>[];
    command.addListener(states.add);
    final pending = command.toggleBookmark(false);
    command.dispose();
    wait.complete(Result.success(_status()));
    await pending;
    expect(states.last.command, isA<CommandSubmitting>());
  });
}

WordStatus _status() => WordStatus(
    word: const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 9),
    isLearned: false,
    isBookmarked: true,
    hasNote: false,
    updatedAt: DateTime.utc(2026));
