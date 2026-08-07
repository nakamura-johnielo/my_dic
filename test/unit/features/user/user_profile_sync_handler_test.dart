import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/cancellation_token.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_sync_checkpoint_store.dart';
import 'package:my_dic/features/user/data/data_source/local/drift_user_profile_dao.dart';
import 'package:my_dic/features/user/data/data_source/local/user_profile_drift_data_source.dart';
import 'package:my_dic/features/user/data/sync/remote/i_user_remote_data_source.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';
import 'package:my_dic/features/user/data/sync/user_profile_sync_handler.dart';

import '../../../helpers/sync/fake_sync_queue.dart';

class _MockRemote extends Mock implements IUserRemoteDataSource {}

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
}) =>
    SyncMutation(
      mutationId: 'mutation-${fieldMask.join('-')}',
      accountId: _accountId,
      dataset: SyncDataset.userProfile,
      entityId: _accountId,
      operation: SyncMutationOperation.upsert,
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
      entityId: _accountId,
      mutationId: 'fallback-mutation',
      fields: const {'username': 'Taro'},
      fieldMask: const ['username'],
      clientUpdatedAt: DateTime.utc(2026),
    ));
  });

  late DatabaseProvider database;
  late UserProfileDao dao;
  late UserProfileDriftDataSource local;
  late _MockRemote remote;
  late FakeSyncQueue queue;
  late UserProfileSyncHandler handler;

  setUp(() {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
    dao = UserProfileDao(database);
    local = UserProfileDriftDataSource(dao);
    remote = _MockRemote();
    queue = FakeSyncQueue();
    final checkpointStore = DriftSyncCheckpointStore(database);
    handler = UserProfileSyncHandler(
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
    await dao.upsertProfileFields(_accountId, {'username': 'Taro'});
    queue.enqueue(_mutation(
      fieldMask: const ['username'],
      payload: const {'username': 'Taro'},
    ));
    when(() => remote.getUserById(_accountId)).thenAnswer((_) async => null);
    when(() => remote.patchUser(any())).thenAnswer((_) async => _ack);

    final result = await handler.run(context());

    expect(result, isA<DatasetSyncSuccess>());
    expect((result as DatasetSyncSuccess).pushedCount, 1);
    expect(queue.pending, isEmpty);
    verify(() => remote.patchUser(any())).called(1);
  });

  test('session invalidation after remote write does not ack', () async {
    queue.enqueue(_mutation(
      fieldMask: const ['username'],
      payload: const {'username': 'Taro'},
    ));
    final cancellation = CancellationToken();
    when(() => remote.patchUser(any())).thenAnswer((_) async {
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
    verify(() => remote.patchUser(any())).called(1);
  });

  test('a retryable remote failure re-queues the mutation as pending',
      () async {
    queue.enqueue(_mutation(
      fieldMask: const ['username'],
      payload: const {'username': 'Taro'},
    ));
    when(() => remote.patchUser(any())).thenThrow(Exception('unavailable'));

    final result = await handler.run(context());

    expect(result, isA<DatasetSyncFailed>());
    expect((result as DatasetSyncFailed).retryable, isTrue);
    expect(queue.pending, hasLength(1));
  });

  test('a pulled remote profile is applied and the checkpoint advances',
      () async {
    final updatedAt = DateTime.utc(2026, 8, 5, 12);
    when(() => remote.getUserById(_accountId)).thenAnswer(
      (_) async => UserDTO(
        userId: _accountId,
        userName: 'Remote Name',
        updatedAt: updatedAt,
      ),
    );

    final result = await handler.run(context());

    expect(result, isA<DatasetSyncSuccess>());
    expect((result as DatasetSyncSuccess).pulledCount, 1);
    final row = await dao.getProfile(_accountId);
    expect(row, isNotNull);
    expect(row!.payload, contains('Remote Name'));
    expect(row.localRevision, 0,
        reason: 'applying a remote snapshot must not look like a local edit');
  });

  test(
      'a pending local username mutation blocks the pulled value from '
      'overwriting it', () async {
    await dao.upsertProfileFields(_accountId, {'username': 'Local Edit'});
    queue.enqueue(_mutation(
      fieldMask: const ['username'],
      payload: const {'username': 'Local Edit'},
    ));
    await queue.leasePending(
      accountId: _accountId,
      dataset: SyncDataset.userProfile,
      limit: 10,
      now: DateTime.utc(2026, 8, 6),
      leaseDuration: const Duration(minutes: 2),
    );
    final updatedAt = DateTime.utc(2026, 8, 5, 12);
    when(() => remote.getUserById(_accountId)).thenAnswer(
      (_) async => UserDTO(
        userId: _accountId,
        userName: 'Remote Name',
        updatedAt: updatedAt,
      ),
    );
    when(() => remote.patchUser(any())).thenAnswer((_) async => _ack);

    await handler.run(context());

    final row = await dao.getProfile(_accountId);
    expect(row!.payload, contains('Local Edit'));
  });
}
