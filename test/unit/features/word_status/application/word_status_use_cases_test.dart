import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/word_status/application/fetch_word_status.dart';
import 'package:my_dic/features/word_status/application/model/update_word_status_command.dart';
import 'package:my_dic/features/word_status/application/port/word_status_repository.dart';
import 'package:my_dic/features/word_status/application/update_word_status.dart';
import 'package:my_dic/features/word_status/application/watch_word_status.dart';
import 'package:my_dic/features/word_status/domain/word_status.dart';

import '../../../../helpers/fake_current_session.dart';

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

      final result =
          await FetchWordStatus(repository, FakeCurrentSession()).execute(word);

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

      await FetchWordStatus(
        repository,
        FakeCurrentSession(accountIdOrNull: 'account-a'),
      ).execute(word);

      verify(() => repository.get(word, accountId: 'account-a')).called(1);
    });
  });

  group('WatchWordStatus', () {
    test('delegates the guest-scoped repository stream', () async {
      final repository = _MockRepository();
      final expected = status();
      when(() => repository.watch(word, accountId: guestAccountScope))
          .thenAnswer((_) => Stream.value(expected));

      final actual = await WatchWordStatus(repository, FakeCurrentSession())
          .execute(word)
          .single;

      expect(actual, same(expected));
    });

    test('uses the signed-in account scope for the repository stream',
        () async {
      final repository = _MockRepository();
      when(() => repository.watch(word, accountId: 'account-b'))
          .thenAnswer((_) => Stream.value(status()));

      await WatchWordStatus(
        repository,
        FakeCurrentSession(accountIdOrNull: 'account-b'),
      ).execute(word).single;

      verify(() => repository.watch(word, accountId: 'account-b')).called(1);
    });
  });

  group('UpdateWordStatus', () {
    test('does not call the repository for an unchanged command', () async {
      final repository = _MockRepository();

      final result = await UpdateWordStatus(repository, FakeCurrentSession())
          .execute(const UpdateWordStatusCommand(word: word));

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
        FakeCurrentSession(accountIdOrNull: 'account-c'),
        clock: () => localTime,
      ).execute(const UpdateWordStatusCommand(
        word: word,
        isBookmarked: FieldUpdate.set(false),
      ));

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

      await UpdateWordStatus(repository, FakeCurrentSession()).execute(
        const UpdateWordStatusCommand(
          word: word,
          hasNote: FieldUpdate.set(true),
        ),
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

      final result = await UpdateWordStatus(repository, FakeCurrentSession())
          .execute(const UpdateWordStatusCommand(
        word: word,
        isLearned: FieldUpdate.set(true),
      ));

      expect(result.errorOrNull, same(error));
    });
  });
}
