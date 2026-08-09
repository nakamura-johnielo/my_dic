import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_word_drift_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_word_status_drift_data_source.dart';
import 'package:my_dic/features/my_word/data/repository_impl/my_word_repository.dart';
import 'package:my_dic/features/my_word/data/repository_impl/my_word_status_repository.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/load_my_word/load_my_word_interactor.dart';
import 'package:my_dic/features/my_word/domain/model/my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/watch/watch_my_word_interactor.dart';
import 'package:my_dic/features/my_word/domain/model/my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/model/my_word_status/update_my_word_status_repository_input_data.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word_status/watch_my_word_status/watch_my_word_status_interactor.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/port/outbox_writer.dart';

import '../../../helpers/fake_current_session.dart';

class _MockOutboxWriter extends Mock implements OutboxWriter {}

class _MockMyWordRepository extends Mock implements IMyWordRepository {}

class _MockMyWordStatusRepository extends Mock
    implements IMyWordStatusRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
        RegisterMyWordRepositoryInputData('w', '', DateTime.utc(2026), null));
    registerFallbackValue(UpdateMyWordStatusRepositoryInputData(
        'w', null, null, null, DateTime.utc(2026), null));
    registerFallbackValue(LoadMyWordRepositoryInputData(0, 0));
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
    late MyWordRepository repository;

    setUp(() {
      database = DatabaseProvider.forTesting(NativeDatabase.memory());
      final local = MyWordDriftDataSource(MyWordDao(database));
      final writer = _MockOutboxWriter();
      when(() => writer.enqueue(any())).thenAnswer((_) async {});
      repository = MyWordRepository(local, writer);
    });

    tearDown(() => database.close());

    test('two signed-in accounts do not see or list each other\'s words',
        () async {
      final aResult = await repository.registerWord(
          RegisterMyWordRepositoryInputData(
              'hola', 'greeting', DateTime.utc(2026, 8, 6), 'account-a'));
      final bResult = await repository.registerWord(
          RegisterMyWordRepositoryInputData(
              'libro', 'book', DateTime.utc(2026, 8, 6), 'account-b'));
      final aWordId = aResult.dataOrNull!;
      final bWordId = bResult.dataOrNull!;

      final aIds = await repository.getIdsFilteredByPage(
          LoadMyWordRepositoryInputData(10, 0),
          accountId: 'account-a');
      final bIds = await repository.getIdsFilteredByPage(
          LoadMyWordRepositoryInputData(10, 0),
          accountId: 'account-b');

      expect(aIds.dataOrNull, [aWordId]);
      expect(bIds.dataOrNull, [bWordId]);

      final crossRead =
          await repository.getById(aWordId, accountId: 'account-b');
      expect(crossRead.isFailure, isTrue);
    });

    test('guest writes are isolated from a signed-in account scope', () async {
      final guestResult = await repository.registerWord(
          RegisterMyWordRepositoryInputData(
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
        RegisterMyWordRepositoryInputData(
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
    late MyWordStatusRepository repository;

    setUp(() {
      database = DatabaseProvider.forTesting(NativeDatabase.memory());
      final local = MyWordStatusDriftDataSource(MyWordStatusDao(database));
      final writer = _MockOutboxWriter();
      when(() => writer.enqueue(any())).thenAnswer((_) async {});
      repository = MyWordStatusRepository(local, writer);
    });

    tearDown(() => database.close());

    test(
        'two signed-in accounts on the same wordId do not overwrite each '
        'other', () async {
      await repository.updateStatus(UpdateMyWordStatusRepositoryInputData(
        'word-1',
        const FieldUpdate.set(true),
        const FieldUpdate.set(false),
        const FieldUpdate.unchanged(),
        DateTime.utc(2026, 8, 6),
        'account-a',
      ));
      await repository.updateStatus(UpdateMyWordStatusRepositoryInputData(
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
      await repository.updateStatus(UpdateMyWordStatusRepositoryInputData(
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

  group('Load/Watch interactors resolve accountId from CurrentSession', () {
    test('LoadMyWordInteractor uses the guest scope when signed out', () async {
      final repository = _MockMyWordRepository();
      when(() => repository.getIdsFilteredByPage(any(),
              accountId: any(named: 'accountId')))
          .thenAnswer((_) async => const Result.success(['w1']));

      final interactor = LoadMyWordInteractor(repository, FakeCurrentSession());
      await interactor.executeIds(LoadMyWordInputData(10, 0));

      verify(() => repository.getIdsFilteredByPage(any(),
          accountId: guestAccountScope)).called(1);
    });

    test('LoadMyWordInteractor uses the real accountId when signed in',
        () async {
      final repository = _MockMyWordRepository();
      when(() => repository.getIdsFilteredByPage(any(),
              accountId: any(named: 'accountId')))
          .thenAnswer((_) async => const Result.success(['w1']));

      final session = FakeCurrentSession(accountIdOrNull: 'account-a');
      final interactor = LoadMyWordInteractor(repository, session);
      await interactor.executeIds(LoadMyWordInputData(10, 0));

      verify(() =>
              repository.getIdsFilteredByPage(any(), accountId: 'account-a'))
          .called(1);
    });

    test('WatchMyWordInteractor resolves CurrentSession accountId scope',
        () async {
      final repository = _MockMyWordRepository();
      when(() =>
              repository.watchMyWord(any(), accountId: any(named: 'accountId')))
          .thenAnswer((_) =>
              Stream.value(MyWord(wordId: 'w1', word: 'hola', contents: '')));

      final signedIn = WatchMyWordInteractor(
          repository, FakeCurrentSession(accountIdOrNull: 'account-c'));
      signedIn.execute('w1');
      verify(() => repository.watchMyWord('w1', accountId: 'account-c'))
          .called(1);

      final guest = WatchMyWordInteractor(repository, FakeCurrentSession());
      guest.execute('w1');
      verify(() => repository.watchMyWord('w1', accountId: guestAccountScope))
          .called(1);
    });

    test(
        'WatchMyWordStatusInteractor resolves CurrentSession accountId '
        'scope', () async {
      final repository = _MockMyWordStatusRepository();
      when(() =>
              repository.watchStatus(any(), accountId: any(named: 'accountId')))
          .thenAnswer((_) => Stream.value(MyWordStatus(wordId: 'w1')));

      final signedIn = WatchMyWordStatusInteractor(
          repository, FakeCurrentSession(accountIdOrNull: 'account-c'));
      signedIn.execute('w1');
      verify(() => repository.watchStatus('w1', accountId: 'account-c'))
          .called(1);

      final guest =
          WatchMyWordStatusInteractor(repository, FakeCurrentSession());
      guest.execute('w1');
      verify(() => repository.watchStatus('w1', accountId: guestAccountScope))
          .called(1);
    });
  });
}
