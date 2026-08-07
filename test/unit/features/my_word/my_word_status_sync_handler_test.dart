import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_word_status_drift_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/status/firebase_my_word_status_dto.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/status/i_my_word_status_remote_data_source.dart';
import 'package:my_dic/features/my_word/data/sync/my_word_status_sync_handler.dart';
import 'package:my_dic/features/sync/application/cancellation_token.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_sync_checkpoint_store.dart';

import '../../../helpers/sync/fake_sync_queue.dart';

class _MockRemote extends Mock implements IMyWordStatusRemoteDataSource {}

const _accountId = 'account-a';

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
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(<String, Object?>{});
    registerFallbackValue(<String>[]);
  });

  late DatabaseProvider database;
  late MyWordStatusDao dao;
  late MyWordStatusDriftDataSource local;
  late _MockRemote remote;
  late FakeSyncQueue queue;
  late MyWordStatusSyncHandler handler;

  setUp(() async {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
    dao = MyWordStatusDao(database);
    local = MyWordStatusDriftDataSource(dao);
    remote = _MockRemote();
    queue = FakeSyncQueue();
    final checkpointStore = DriftSyncCheckpointStore(database);
    handler = MyWordStatusSyncHandler(
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

  test('pushes a leased mutation as a field-mask patch and acks it', () async {
    queue.enqueue(_mutation(
      fieldMask: const ['isBookmarked'],
      payload: const {'isBookmarked': true},
    ));
    when(() => remote.getStatusById(_accountId, 'word-1'))
        .thenAnswer((_) async => null);
    when(() => remote.patchStatus(
          _accountId,
          'word-1',
          any(),
          any(),
          isNew: any(named: 'isNew'),
        )).thenAnswer((_) async {});
    when(() => remote.getStatusAfter(_accountId, any()))
        .thenAnswer((_) async => const []);

    final result = await handler.run(context());

    expect(result, isA<DatasetSyncSuccess>());
    expect((result as DatasetSyncSuccess).pushedCount, 1);
    expect(queue.pending, isEmpty);
  });

  test('a retryable remote failure re-queues the mutation as pending',
      () async {
    queue.enqueue(_mutation(
      fieldMask: const ['isLearned'],
      payload: const {'isLearned': true},
    ));
    when(() => remote.getStatusById(_accountId, 'word-1'))
        .thenThrow(Exception('unavailable'));
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
    final row = await dao.getWordStatus('word-2');
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
        DateTime.utc(2026, 8, 1).toIso8601String());
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

    final row = await dao.getWordStatus('word-3');
    expect(row, isNotNull);
    expect(row!.isLearned, 1);
    expect(row.isBookmarked, 1,
        reason: 'isBookmarked keeps the not-yet-pushed local value instead '
            'of the remote stale value');
  });
}
