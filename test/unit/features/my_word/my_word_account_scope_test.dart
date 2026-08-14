import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/store/drift_my_word_store.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/store/drift_my_word_status_store.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/repository/drift_my_word_repository.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/repository/drift_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/my_word_page_query.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/register_my_word_record.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/update_my_word_status_record.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';

class _MockOutboxWriter extends Mock implements OutboxWriter {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
        RegisterMyWordRecord('w', '', DateTime.utc(2026), null));
    registerFallbackValue(UpdateMyWordStatusRecord(
        'w', null, null, null, DateTime.utc(2026), null));
    registerFallbackValue(MyWordPageQuery(0, 0));
    registerFallbackValue(SyncMutation(
      mutationId: 'fallback',
      accountId: 'fallback',
      dataset: SyncDataset.myWords,
      entityId: '0',
      operation: SyncMutationOperation.patch,
      payload: const {},
      fieldMask: const [],
      localRevision: 0,
      clientUpdatedAt: DateTime.utc(2026),
    ));
  });

  group('MyWord local row account scoping', () {
    late DatabaseProvider database;
    late DriftMyWordRepository repository;

    setUp(() {
      database = DatabaseProvider.forTesting(NativeDatabase.memory());
      final local = DriftMyWordStore(MyWordDao(database));
      final writer = _MockOutboxWriter();
      when(() => writer.enqueue(any())).thenAnswer((_) async {});
      repository = DriftMyWordRepository(local, writer);
    });

    tearDown(() => database.close());

    test('two signed-in accounts do not see or list each other\'s words',
        () async {
      final aResult = await repository.registerWord(
          RegisterMyWordRecord(
              'hola', 'greeting', DateTime.utc(2026, 8, 6), 'account-a'));
      final bResult = await repository.registerWord(
          RegisterMyWordRecord(
              'libro', 'book', DateTime.utc(2026, 8, 6), 'account-b'));
      final aWordId = aResult.dataOrNull!;
      final bWordId = bResult.dataOrNull!;

      final aIds = await repository.getIdsFilteredByPage(
          MyWordPageQuery(10, 0),
          accountId: 'account-a');
      final bIds = await repository.getIdsFilteredByPage(
          MyWordPageQuery(10, 0),
          accountId: 'account-b');

      expect(aIds.dataOrNull, [aWordId]);
      expect(bIds.dataOrNull, [bWordId]);

      final crossRead =
          await repository.getById(aWordId, accountId: 'account-b');
      expect(crossRead.isFailure, isTrue);
    });

    test('guest writes are isolated from a signed-in account scope', () async {
      final guestResult = await repository.registerWord(
          RegisterMyWordRecord(
              'perro', 'dog', DateTime.utc(2026, 8, 6), null));
      final wordId = guestResult.dataOrNull!;

      final asAccount =
          await repository.getById(wordId, accountId: 'account-a');
      final asGuest =
          await repository.getById(wordId, accountId: guestAccountScope);

      expect(asAccount.isFailure, isTrue);
      expect(asGuest.isSuccess, isTrue);
      expect(asGuest.dataOrNull!.word, 'perro');
    });

    test('maps persisted write fields without status data', () async {
      final registered = await repository.registerWord(
        RegisterMyWordRecord(
          'casa',
          'house',
          DateTime.utc(2026, 8, 6),
          'account-a',
        ),
      );

      final word = await repository.getById(
        registered.dataOrNull!,
        accountId: 'account-a',
      );

      expect(word.dataOrNull!.word, 'casa');
      expect(word.dataOrNull!.contents, 'house');
    });
  });

  group('MyWordStatus local row account scoping', () {
    late DatabaseProvider database;
    late DriftMyWordStatusRepository repository;

    setUp(() {
      database = DatabaseProvider.forTesting(NativeDatabase.memory());
      final local = DriftMyWordStatusStore(MyWordStatusDao(database));
      final writer = _MockOutboxWriter();
      when(() => writer.enqueue(any())).thenAnswer((_) async {});
      repository = DriftMyWordStatusRepository(local, writer);
    });

    tearDown(() => database.close());

    test(
        'two signed-in accounts on the same wordId do not overwrite each '
        'other', () async {
      await repository.updateStatus(UpdateMyWordStatusRecord(
        'word-1',
        const FieldUpdate.set(true),
        const FieldUpdate.set(false),
        const FieldUpdate.unchanged(),
        DateTime.utc(2026, 8, 6),
        'account-a',
      ));
      await repository.updateStatus(UpdateMyWordStatusRecord(
        'word-1',
        const FieldUpdate.set(false),
        const FieldUpdate.set(true),
        const FieldUpdate.unchanged(),
        DateTime.utc(2026, 8, 6),
        'account-b',
      ));

      final aStatus =
          await repository.watchStatus('word-1', accountId: 'account-a').first;
      final bStatus =
          await repository.watchStatus('word-1', accountId: 'account-b').first;

      expect(aStatus.isLearned, isTrue);
      expect(aStatus.isBookmarked, isFalse);
      expect(bStatus.isLearned, isFalse);
      expect(bStatus.isBookmarked, isTrue);
    });

    test('guest writes are isolated from a signed-in account scope', () async {
      await repository.updateStatus(UpdateMyWordStatusRecord(
          'word-1', 1, 1, null, DateTime.utc(2026, 8, 6), null));

      final asAccount =
          await repository.watchStatus('word-1', accountId: 'account-a').first;
      final asGuest = await repository
          .watchStatus('word-1', accountId: guestAccountScope)
          .first;

      expect(asAccount.isLearned, isFalse);
      expect(asAccount.isBookmarked, isFalse);
      expect(asGuest.isLearned, isTrue);
      expect(asGuest.isBookmarked, isTrue);
    });
  });

}
