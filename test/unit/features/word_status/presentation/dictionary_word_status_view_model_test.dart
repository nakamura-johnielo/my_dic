import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_status/internal/application/update_word_status.dart';
import 'package:my_dic/features/word_status/port/repository.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';
import 'package:my_dic/features/word_status/internal/presentation/dictionary_status/dictionary_word_status_command.dart';
import 'package:my_dic/features/word_status/internal/presentation/dictionary_status/dictionary_word_status_view_model.dart';

class _MockRepository extends Mock implements WordStatusRepository {}

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
    registerFallbackValue(word);
    registerFallbackValue(const FieldUpdate<bool>.unchanged());
  });

  group('WordStatusState', () {
    test('keeps previous data while loading', () {
      final state = WordStatusState.fromAsync(
          AsyncLoading<WordStatus>().copyWithPrevious(AsyncData(status)));

      expect(state.status, isA<QueryLoading<WordStatus>>());
      expect(state.isLearned, isTrue);
      expect(state.hasNote, isTrue);
    });

    test('turns a read exception into a query failure with previous data', () {
      final state = WordStatusState.fromAsync(
        AsyncError<WordStatus>(StateError('offline'), StackTrace.empty)
            .copyWithPrevious(AsyncData(status)),
      );

      expect(state.status, isA<QueryFailure<WordStatus>>());
      expect(state.status.dataOrNull, same(status));
    });
  });

  group('WordStatusCommand', () {
    test('uses its CatalogWordRef and emits the matching success event',
        () async {
      final repository = _MockRepository();
      when(() => repository.update(
            any(),
            isLearned: any(named: 'isLearned'),
            isBookmarked: any(named: 'isBookmarked'),
            hasNote: any(named: 'hasNote'),
            updatedAt: any(named: 'updatedAt'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => Result.success(status));
      final command = DictionaryWordStatusCommand(
        word,
        UpdateWordStatus(repository),
        const SessionScopeKey(accountScope: 'guest', epoch: 1),
      );

      await command.toggleBookmark(false);

      expect(command.state.command, isA<CommandSucceeded>());
      final captured = verify(() => repository.update(
            word,
            isLearned: captureAny(named: 'isLearned'),
            isBookmarked: captureAny(named: 'isBookmarked'),
            hasNote: captureAny(named: 'hasNote'),
            updatedAt: any(named: 'updatedAt'),
            accountId: 'guest',
          )).captured;
      expect(captured[0], isA<Unchanged<bool>>());
      expect(captured[1],
          isA<SetValue<bool>>().having((value) => value.value, 'value', true));
      expect(captured[2], isA<Unchanged<bool>>());
    });

    test('emits a failure event when the update fails', () async {
      final repository = _MockRepository();
      when(() => repository.update(
                any(),
                isLearned: any(named: 'isLearned'),
                isBookmarked: any(named: 'isBookmarked'),
                hasNote: any(named: 'hasNote'),
                updatedAt: any(named: 'updatedAt'),
                accountId: any(named: 'accountId'),
              ))
          .thenAnswer(
              (_) async => Result.failure(DatabaseError(message: 'nope')));
      final command = DictionaryWordStatusCommand(
        word,
        UpdateWordStatus(repository),
        const SessionScopeKey(accountScope: 'guest', epoch: 1),
      );

      await command.toggleLearned(false);

      expect(command.state.command, isA<CommandFailed>());
    });
  });
}
