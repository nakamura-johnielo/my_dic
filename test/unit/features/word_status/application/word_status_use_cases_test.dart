import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_status/internal/application/fetch_word_status.dart';
import 'package:my_dic/features/word_status/internal/application/update_word_status.dart';
import 'package:my_dic/features/word_status/internal/application/watch_word_status.dart';
import 'package:my_dic/features/word_status/port/commands.dart';
import 'package:my_dic/features/word_status/port/repository.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

class _MockRepository extends Mock implements WordStatusRepository {}

void main() {
  const word = CatalogWordRef(
    catalogId: CatalogId.espJpnMain,
    wordId: 7,
  );

  setUpAll(() {
    registerFallbackValue(word);
    registerFallbackValue(const FieldUpdate<bool>.unchanged());
  });

  WordStatus status() => WordStatus(
        word: word,
        isLearned: true,
        isBookmarked: false,
        hasNote: true,
        updatedAt: DateTime.utc(2026, 8, 9),
      );

  group('FetchWordStatus', () {
    test('returns an all-false default status when the scoped row is missing',
        () async {
      final repository = _MockRepository();
      when(() => repository.get(word, accountId: guestAccountScope))
          .thenAnswer((_) async => const Result.success(null));

      final result = await FetchWordStatus(repository)
          .execute(word, accountScope: guestAccountScope);

      final fetched = result.dataOrNull!;
      expect(fetched.word, word);
      expect(fetched.isLearned, isFalse);
      expect(fetched.isBookmarked, isFalse);
      expect(fetched.hasNote, isFalse);
      expect(fetched.updatedAt.isUtc, isTrue);
    });

    test('resolves a signed-in account scope once for the repository read',
        () async {
      final repository = _MockRepository();
      when(() => repository.get(word, accountId: 'account-a'))
          .thenAnswer((_) async => Result.success(status()));

      await FetchWordStatus(repository)
          .execute(word, accountScope: 'account-a');

      verify(() => repository.get(word, accountId: 'account-a')).called(1);
    });
  });

  group('WatchWordStatus', () {
    test('delegates the guest-scoped repository stream', () async {
      final repository = _MockRepository();
      final expected = status();
      when(() => repository.watch(word, accountId: guestAccountScope))
          .thenAnswer((_) => Stream.value(expected));

      final actual = await WatchWordStatus(repository)
          .execute(word, accountScope: guestAccountScope)
          .single;

      expect(actual, same(expected));
    });

    test('uses the signed-in account scope for the repository stream',
        () async {
      final repository = _MockRepository();
      when(() => repository.watch(word, accountId: 'account-b'))
          .thenAnswer((_) => Stream.value(status()));

      await WatchWordStatus(repository)
          .execute(word, accountScope: 'account-b')
          .single;

      verify(() => repository.watch(word, accountId: 'account-b')).called(1);
    });
  });

  group('UpdateWordStatus', () {
    test('does not call the repository for an unchanged command', () async {
      final repository = _MockRepository();

      final result = await UpdateWordStatus(repository).execute(
        const UpdateWordStatusCommand(word: word),
        accountId: null,
      );

      expect(result.isSuccess, isTrue);
      verifyNever(() => repository.update(
            any(),
            isLearned: any(named: 'isLearned'),
            isBookmarked: any(named: 'isBookmarked'),
            hasNote: any(named: 'hasNote'),
            updatedAt: any(named: 'updatedAt'),
            accountId: any(named: 'accountId'),
          ));
    });

    test('passes a UTC timestamp and signed-in account to the repository',
        () async {
      final repository = _MockRepository();
      when(() => repository.update(
            any(),
            isLearned: any(named: 'isLearned'),
            isBookmarked: any(named: 'isBookmarked'),
            hasNote: any(named: 'hasNote'),
            updatedAt: any(named: 'updatedAt'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => Result.success(status()));
      final localTime = DateTime(2026, 8, 9, 10, 30);

      await UpdateWordStatus(
        repository,
        clock: () => localTime,
      ).execute(
          const UpdateWordStatusCommand(
            word: word,
            isBookmarked: FieldUpdate.set(false),
          ),
          accountId: 'account-c');

      final invocation = verify(() => repository.update(
            word,
            isLearned: any(named: 'isLearned'),
            isBookmarked: any(named: 'isBookmarked'),
            hasNote: any(named: 'hasNote'),
            updatedAt: captureAny(named: 'updatedAt'),
            accountId: 'account-c',
          )).captured.single as DateTime;
      expect(invocation, localTime.toUtc());
      expect(invocation.isUtc, isTrue);
    });

    test('passes a guest update without an account ID', () async {
      final repository = _MockRepository();
      when(() => repository.update(
            any(),
            isLearned: any(named: 'isLearned'),
            isBookmarked: any(named: 'isBookmarked'),
            hasNote: any(named: 'hasNote'),
            updatedAt: any(named: 'updatedAt'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => Result.success(status()));

      await UpdateWordStatus(repository).execute(
        const UpdateWordStatusCommand(
          word: word,
          hasNote: FieldUpdate.set(true),
        ),
        accountId: null,
      );

      verify(() => repository.update(
            word,
            isLearned: any(named: 'isLearned'),
            isBookmarked: any(named: 'isBookmarked'),
            hasNote: any(named: 'hasNote'),
            updatedAt: any(named: 'updatedAt'),
            accountId: null,
          )).called(1);
    });

    test('preserves the repository AppError instance', () async {
      final repository = _MockRepository();
      final error = DatabaseError(message: 'local update failed');
      when(() => repository.update(
            any(),
            isLearned: any(named: 'isLearned'),
            isBookmarked: any(named: 'isBookmarked'),
            hasNote: any(named: 'hasNote'),
            updatedAt: any(named: 'updatedAt'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => Result.failure(error));

      final result = await UpdateWordStatus(repository).execute(
          const UpdateWordStatusCommand(
            word: word,
            isLearned: FieldUpdate.set(true),
          ),
          accountId: null);

      expect(result.errorOrNull, same(error));
    });
  });
}
