import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/word_status/internal/presentation/model/dictionary_word_status_command.dart';
import 'package:my_dic/features/word_status/internal/presentation/viewmodel/dictionary_word_status_view_model.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

class _MockCommands extends Mock implements WordStatusCommandPort {}

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 42);
  final status = WordStatus(
    word: word,
    isLearned: true,
    isBookmarked: false,
    hasNote: true,
    updatedAt: DateTime.utc(2026, 8, 9),
  );

  setUpAll(() {
    registerFallbackValue(const UpdateWordStatusCommand(
      scope: WordStatusScope.guest(),
      word: word,
    ));
  });

  group('WordStatusState', () {
    test('keeps previous data while loading', () {
      final state = WordStatusState.fromAsync(
        AsyncLoading<Result<WordStatus>>().copyWithPrevious(
          AsyncData(Result.success(status)),
        ),
      );

      expect(state.status, isA<QueryLoading<WordStatus>>());
      expect(state.isLearned, isTrue);
      expect(state.hasNote, isTrue);
    });

    test('turns a read exception into a query failure with previous data', () {
      final state = WordStatusState.fromAsync(
        AsyncError<Result<WordStatus>>(
          StateError('offline'),
          StackTrace.empty,
        ).copyWithPrevious(AsyncData(Result.success(status))),
      );

      expect(state.status, isA<QueryFailure<WordStatus>>());
      expect(state.status.dataOrNull, same(status));
    });
  });

  group('WordStatusCommand', () {
    test('uses its CatalogWordRef and emits the matching success event',
        () async {
      final commands = _MockCommands();
      when(() => commands.update(any()))
          .thenAnswer((_) async => const Result.success(null));
      final command = DictionaryWordStatusCommand(
        word,
        commands,
        const SessionScopeKey(accountScope: 'account-a', epoch: 1),
      );

      await command.toggleBookmark(false);

      expect(command.state.command, isA<CommandSucceeded>());
      final captured = verify(() => commands.update(captureAny())).captured.single
          as UpdateWordStatusCommand;
      expect(captured.word, word);
      expect(captured.scope, WordStatusScope.account('account-a'));
      expect(captured.isLearned, isA<Unchanged<bool>>());
      expect(captured.isBookmarked,
          isA<SetValue<bool>>().having((value) => value.value, 'value', true));
      expect(captured.hasNote, isA<Unchanged<bool>>());
    });

    test('emits a failure event when the update fails', () async {
      final commands = _MockCommands();
      when(() => commands.update(any())).thenAnswer(
        (_) async =>
            const Result.failure(WordStatusWriteError.storage()),
      );
      final command = DictionaryWordStatusCommand(
        word,
        commands,
        const SessionScopeKey(accountScope: 'account-a', epoch: 1),
      );

      await command.toggleLearned(false);

      expect(command.state.command, isA<CommandFailed>());
    });
  });
}
