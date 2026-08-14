import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/store/drift_my_word_status_store.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_dto.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/my_word_status_remote_gateway.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/sync/my_word_status_dataset_sync_service.dart';
import 'package:my_dic/features/sync/internal/application/in_memory_session_fence.dart';
import 'package:my_dic/features/sync/internal/application/sync_handler_runtime_service.dart';
import 'package:my_dic/features/sync/port/cancellation_token.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/internal/infrastructure/persistence/drift/drift_sync_checkpoint_store.dart';

import '../../../helpers/sync/fake_sync_queue.dart';

class _MockRemote extends Mock implements MyWordStatusRemoteGateway {}

const _accountId = 'account-a';

const _ack = RemoteMutationAck(
  status: RemoteMutationAckStatus.applied,
  remoteRevision: 1,
  lastMutationId: 'remote-mutation',
  serverUpdatedAt: null,
);

SyncMutation _mutation({
  required List<String> fieldMask,
  required Map<String, Object?> payload,
  int localRevision = 1,
  String entityId = 'word-1',
}) =>
    SyncMutation(
      mutationId: 'mutation-$entityId-${fieldMask.join('-')}',
      accountId: _accountId,
      dataset: SyncDataset.myWordStatus,
      entityId: entityId,
      operation: SyncMutationOperation.patch,
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
      fields: const {'isLearned': 1},
      fieldMask: const ['isLearned'],
      clientUpdatedAt: DateTime.utc(2026),
    ));
  });

  late DatabaseProvider database;
  late MyWordStatusDao dao;
  late DriftMyWordStatusStore local;
  late _MockRemote remote;
  late FakeSyncQueue queue;
  late DatasetSyncHandler handler;
  late InMemorySessionFence fence;

  setUp(() async {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
    dao = MyWordStatusDao(database);
    local = DriftMyWordStatusStore(dao);
    remote = _MockRemote();
    queue = FakeSyncQueue();
    fence = InMemorySessionFence()..setCurrent(_accountId, 1);
    final checkpointStore = DriftSyncCheckpointStore(database);
    handler = DatasetSyncService(
        adapter: MyWordStatusDatasetSyncService(local: local, remote: remote),
        runtime: SyncHandlerRuntimeService(
            queue: queue,
            checkpoints: checkpointStore,
            sessionFence: fence,
            clock: () => DateTime.utc(2026, 8, 6)));
  });

  tearDown(() => database.close());

  SyncContext context() => SyncContext(
        accountId: _accountId,
        sessionEpoch: 1,
        reason: 'test',
        cancellation: CancellationToken(),
      );

  test('pushes a leased mutation as a field-mask patch and acks it', () async {
    await dao.applyStatusPatch('word-1', 0, 0, 0,
        DateTime.utc(2026, 8, 1).toIso8601String(), _accountId);
    queue.enqueue(_mutation(
      fieldMask: const ['isBookmarked'],
      payload: const {'isBookmarked': true},
    ));
    when(() => remote.getStatusById(_accountId, 'word-1'))
        .thenAnswer((_) async => null);
    when(() => remote.patchStatus(any())).thenAnswer((_) async => _ack);
    when(() => remote.getStatusAfter(_accountId, any()))
        .thenAnswer((_) async => const []);

    final result = await handler.run(context());

    expect(result, isA<DatasetSyncSuccess>());
    expect((result as DatasetSyncSuccess).pushedCount, 1);
    expect(queue.pending, isEmpty);
  });

  test('session invalidation after remote write does not ack', () async {
    queue.enqueue(_mutation(
      fieldMask: const ['isLearned'],
      payload: const {'isLearned': true},
    ));
    final cancellation = CancellationToken();
    when(() => remote.patchStatus(any())).thenAnswer((_) async {
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
    verify(() => remote.patchStatus(any())).called(1);
  });

  test('a retryable remote failure re-queues the mutation as pending',
      () async {
    queue.enqueue(_mutation(
      fieldMask: const ['isLearned'],
      payload: const {'isLearned': true},
    ));
    when(() => remote.patchStatus(any())).thenThrow(Exception('unavailable'));
    when(() => remote.getStatusAfter(_accountId, any()))
        .thenAnswer((_) async => const []);

    final result = await handler.run(context());

    expect(result, isA<DatasetSyncFailed>());
    expect((result as DatasetSyncFailed).retryable, isTrue);
    expect(queue.pending, hasLength(1));
  });

  test('pulled remote fields are applied and the checkpoint advances',
      () async {
    final updatedAt = DateTime.utc(2026, 8, 5, 12);
    when(() => remote.getStatusAfter(_accountId, any())).thenAnswer(
      (_) async => [
        MyWordStatusDTO(
          myWordId: 'word-2',
          isLearned: 1,
          isBookmarked: 0,
          createdAt: updatedAt,
          updatedAt: updatedAt,
        ),
      ],
    );

    final result = await handler.run(context());

    expect(result, isA<DatasetSyncSuccess>());
    expect((result as DatasetSyncSuccess).pulledCount, 1);
    final row = await dao.getWordStatus('word-2', _accountId);
    expect(row, isNotNull);
    expect(row!.isLearned, 1);
    expect(row.isBookmarked, 0);
    expect(row.localRevision, 0,
        reason: 'applying a remote snapshot must not look like a local '
            'edit');
    expect(queue.pending, isEmpty);
  });

  test('a pulled field with an in-flight local mutation is not overwritten',
      () async {
    await dao.applyStatusPatch('word-3', 0, 1, 0,
        DateTime.utc(2026, 8, 1).toIso8601String(), _accountId);
    queue.enqueue(_mutation(
      entityId: 'word-3',
      fieldMask: const ['isBookmarked'],
      payload: const {'isBookmarked': true},
    ));
    await queue.leasePending(
      accountId: _accountId,
      dataset: SyncDataset.myWordStatus,
      limit: 10,
      now: DateTime.utc(2026, 8, 6),
      leaseDuration: const Duration(minutes: 5),
    );
    final updatedAt = DateTime.utc(2026, 8, 5, 12);
    when(() => remote.getStatusAfter(_accountId, any())).thenAnswer(
      (_) async => [
        MyWordStatusDTO(
          myWordId: 'word-3',
          isLearned: 1,
          isBookmarked: 0,
          createdAt: updatedAt,
          updatedAt: updatedAt,
        ),
      ],
    );

    await handler.run(context());

    final row = await dao.getWordStatus('word-3', _accountId);
    expect(row, isNotNull);
    expect(row!.isLearned, 1);
    expect(row.isBookmarked, 1,
        reason: 'isBookmarked keeps the not-yet-pushed local value instead '
            'of the remote stale value');
  });
}
