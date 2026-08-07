import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_word_drift_data_source.dart';
import 'package:my_dic/features/my_word/data/sync/remote/myword/firebase_my_word_dto.dart';
import 'package:my_dic/features/my_word/data/sync/remote/myword/i_my_word_remote_data_source.dart';
import 'package:my_dic/features/my_word/data/sync/my_word_sync_handler.dart';
import 'package:my_dic/features/sync/application/cancellation_token.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_sync_checkpoint_store.dart';

import '../../../helpers/sync/fake_sync_queue.dart';

class _MockRemote extends Mock implements IMyWordRemoteDataSource {}

const _accountId = 'account-a';

const _ack = RemoteMutationAck(
  status: RemoteMutationAckStatus.applied,
  remoteRevision: 1,
  lastMutationId: 'remote-mutation',
  serverUpdatedAt: null,
);

SyncMutation _mutation({
  required SyncMutationOperation operation,
  required List<String> fieldMask,
  required Map<String, Object?> payload,
  int localRevision = 1,
  String entityId = 'word-1',
}) =>
    SyncMutation(
      mutationId: 'mutation-$entityId-${fieldMask.join('-')}',
      accountId: _accountId,
      dataset: SyncDataset.myWords,
      entityId: entityId,
      operation: operation,
      payload: payload,
      fieldMask: fieldMask,
      localRevision: localRevision,
      clientUpdatedAt: DateTime.utc(2026),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(<String, Object?>{});
    registerFallbackValue(<String>[]);
    registerFallbackValue(RemoteMutationRequest(
      accountId: _accountId,
      entityId: 'word-1',
      mutationId: 'fallback-mutation',
      fields: const {'word': 'hola'},
      fieldMask: const ['word'],
      clientUpdatedAt: DateTime.utc(2026),
    ));
  });

  late DatabaseProvider database;
  late MyWordDao dao;
  late MyWordDriftDataSource local;
  late _MockRemote remote;
  late FakeSyncQueue queue;
  late MyWordSyncHandler handler;

  setUp(() async {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
    dao = MyWordDao(database);
    local = MyWordDriftDataSource(dao);
    remote = _MockRemote();
    queue = FakeSyncQueue();
    final checkpointStore = DriftSyncCheckpointStore(database);
    handler = MyWordSyncHandler(
      queue: queue,
      checkpointStore: checkpointStore,
      local: local,
      remote: remote,
      clock: () => DateTime.utc(2026, 8, 6),
    );
  });

  tearDown(() => database.close());

  SyncContext context() => SyncContext(
        accountId: _accountId,
        sessionEpoch: 1,
        reason: 'test',
        cancellation: CancellationToken(),
      );

  group('MyWord sync handler push', () {
    test('pushes an upsert mutation as a field-mask patch and acks it',
        () async {
      await dao.insertMyWordWithRevision(
        id: 'word-1',
        word: 'hola',
        contents: 'greeting',
        editAt: DateTime.utc(2026, 8, 1).toIso8601String(),
        accountId: _accountId,
      );
      queue.enqueue(_mutation(
        operation: SyncMutationOperation.upsert,
        fieldMask: const ['word', 'contents'],
        payload: const {'word': 'hola', 'contents': 'greeting'},
      ));
      when(() => remote.getMyWordById(_accountId, 'word-1'))
          .thenAnswer((_) async => null);
      when(() => remote.patchMyWord(any())).thenAnswer((_) async => _ack);
      when(() => remote.getMyWordsAfter(_accountId, any()))
          .thenAnswer((_) async => const []);

      final result = await handler.run(context());

      expect(result, isA<DatasetSyncSuccess>());
      expect((result as DatasetSyncSuccess).pushedCount, 1);
      expect(queue.pending, isEmpty);
      expect(queue.leased, isEmpty);
      verify(() => remote.patchMyWord(any())).called(1);
    });

    test('pushes a delete mutation using the same patch contract', () async {
      await dao.insertMyWordWithRevision(
        id: 'word-1',
        word: 'hola',
        contents: 'greeting',
        editAt: DateTime.utc(2026, 8, 1).toIso8601String(),
        accountId: _accountId,
      );
      queue.enqueue(_mutation(
        operation: SyncMutationOperation.delete,
        fieldMask: const ['deletedAt'],
        payload: {'deletedAt': DateTime.utc(2026, 8, 6).toIso8601String()},
      ));
      when(() => remote.getMyWordById(_accountId, 'word-1'))
          .thenAnswer((_) async => MyWordDTO(
                myWordId: 'word-1',
                word: 'hola',
                contents: 'greeting',
                createdAt: DateTime.utc(2026, 8, 1),
                updatedAt: DateTime.utc(2026, 8, 1),
              ));
      when(() => remote.patchMyWord(any())).thenAnswer((_) async => _ack);
      when(() => remote.getMyWordsAfter(_accountId, any()))
          .thenAnswer((_) async => const []);

      final result = await handler.run(context());

      expect(result, isA<DatasetSyncSuccess>());
      expect((result as DatasetSyncSuccess).pushedCount, 1);
      verify(() => remote.patchMyWord(any())).called(1);
    });

    test('session invalidation after remote write does not ack', () async {
      queue.enqueue(_mutation(
        operation: SyncMutationOperation.patch,
        fieldMask: const ['word'],
        payload: const {'word': 'hola!'},
      ));
      final cancellation = CancellationToken();
      when(() => remote.patchMyWord(any())).thenAnswer((_) async {
        cancellation.cancel('account changed');
        return _ack;
      });

      final result = await handler.run(SyncContext(
        accountId: _accountId,
        sessionEpoch: 1,
        reason: 'test',
        cancellation: cancellation,
      ));

      expect(result, isA<DatasetSyncCancelled>());
      expect(queue.leased, hasLength(1));
      expect(queue.pending, isEmpty);
      verify(() => remote.patchMyWord(any())).called(1);
    });

    test('a retryable remote failure re-queues the mutation as pending',
        () async {
      queue.enqueue(_mutation(
        operation: SyncMutationOperation.patch,
        fieldMask: const ['word'],
        payload: const {'word': 'hola!'},
      ));
      when(() => remote.patchMyWord(any())).thenThrow(Exception('unavailable'));
      when(() => remote.getMyWordsAfter(_accountId, any()))
          .thenAnswer((_) async => const []);

      final result = await handler.run(context());

      expect(result, isA<DatasetSyncFailed>());
      expect((result as DatasetSyncFailed).retryable, isTrue);
      expect(queue.pending, hasLength(1));
      expect(queue.deadLetters, isEmpty);
    });

    test('an invalid payload failure dead-letters the mutation', () async {
      queue.enqueue(_mutation(
        operation: SyncMutationOperation.patch,
        fieldMask: const ['word'],
        payload: const {'word': 'hola!'},
      ));
      when(() => remote.patchMyWord(any()))
          .thenThrow(Exception('invalid-argument'));
      when(() => remote.getMyWordsAfter(_accountId, any()))
          .thenAnswer((_) async => const []);

      final result = await handler.run(context());

      expect(result, isA<DatasetSyncFailed>());
      expect((result as DatasetSyncFailed).retryable, isFalse);
      expect(queue.pending, isEmpty);
      expect(queue.deadLetters, hasLength(1));
    });
  });

  group('MyWord sync handler pull', () {
    test('pulled remote fields are applied and the checkpoint advances',
        () async {
      final updatedAt = DateTime.utc(2026, 8, 5, 12);
      when(() => remote.getMyWordsAfter(_accountId, any())).thenAnswer(
        (_) async => [
          MyWordDTO(
            myWordId: 'word-2',
            word: 'libro',
            contents: 'book',
            createdAt: updatedAt,
            updatedAt: updatedAt,
          ),
        ],
      );

      final result = await handler.run(context());

      expect(result, isA<DatasetSyncSuccess>());
      expect((result as DatasetSyncSuccess).pulledCount, 1);
      final row = await dao.getMyWordById('word-2', _accountId);
      expect(row, isNotNull);
      expect(row!.word, 'libro');
      expect(row.contents, 'book');
      expect(row.localRevision, 0,
          reason: 'applying a remote snapshot must not look like a local '
              'edit');
      expect(queue.pending, isEmpty,
          reason: 'applying a remote snapshot must not enqueue an outbox '
              'mutation');
    });

    test('a pulled field with an in-flight local mutation is not overwritten',
        () async {
      await dao.insertMyWordWithRevision(
        id: 'word-3',
        word: 'casa',
        contents: 'house',
        editAt: DateTime.utc(2026, 8, 1).toIso8601String(),
        accountId: _accountId,
      );
      // The pending local edit has already been applied to the row itself
      // (mirroring registerWord/updateWord writing row + outbox together);
      // only the matching outbox mutation is faked here.
      await dao.updateMyWordWithRevision(
        id: 'word-3',
        word: 'casa',
        contents: 'house (pending)',
        editAt: DateTime.utc(2026, 8, 2).toIso8601String(),
        accountId: _accountId,
      );
      queue.enqueue(_mutation(
        operation: SyncMutationOperation.patch,
        entityId: 'word-3',
        fieldMask: const ['contents'],
        payload: const {'contents': 'house (pending)'},
      ));
      // Simulate the mutation already being leased by an earlier/concurrent
      // push attempt, so peekPending still reports it in-flight while this
      // run's own push phase has nothing new to lease for word-3.
      await queue.leasePending(
        accountId: _accountId,
        dataset: SyncDataset.myWords,
        limit: 10,
        now: DateTime.utc(2026, 8, 6),
        leaseDuration: const Duration(minutes: 5),
      );
      final updatedAt = DateTime.utc(2026, 8, 5, 12);
      when(() => remote.getMyWordsAfter(_accountId, any())).thenAnswer(
        (_) async => [
          MyWordDTO(
            myWordId: 'word-3',
            word: 'casa!',
            contents: 'house (stale remote)',
            createdAt: updatedAt,
            updatedAt: updatedAt,
          ),
        ],
      );

      await handler.run(context());

      final row = await dao.getMyWordById('word-3', _accountId);
      expect(row, isNotNull);
      // word comes from the remote snapshot; contents keeps the not-yet-
      // pushed local pending value instead of the remote's stale value.
      expect(row!.word, 'casa!');
      expect(row.contents, 'house (pending)');
    });

    test('a remote tombstone hides the word locally without an outbox entry',
        () async {
      await dao.insertMyWordWithRevision(
        id: 'word-4',
        word: 'perro',
        contents: 'dog',
        editAt: DateTime.utc(2026, 8, 1).toIso8601String(),
        accountId: _accountId,
      );
      final updatedAt = DateTime.utc(2026, 8, 5, 12);
      when(() => remote.getMyWordsAfter(_accountId, any())).thenAnswer(
        (_) async => [
          MyWordDTO(
            myWordId: 'word-4',
            word: 'perro',
            contents: 'dog',
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: updatedAt,
            deletedAt: updatedAt,
          ),
        ],
      );

      await handler.run(context());

      final row = await dao.getMyWordById('word-4', _accountId);
      expect(row, isNull);
      expect(queue.pending, isEmpty);
    });
  });
}
