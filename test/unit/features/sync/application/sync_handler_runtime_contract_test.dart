import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/sync/internal/application/in_memory_session_fence.dart';
import 'package:my_dic/features/sync/internal/application/policy/retry_policy.dart';
import 'package:my_dic/features/sync/internal/application/sync_handler_runtime_adapter.dart';
import 'package:my_dic/features/sync/port/cancellation_token.dart';
import 'package:my_dic/features/sync/port/dataset_sync_adapter.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/port/model/mutation_lease.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/model/sync_cursor.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/sync_checkpoint_store.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';
import 'package:my_dic/features/sync/port/sync_queue.dart';
import 'package:my_dic/features/sync/port/sync_reason_codes.dart';
import 'package:my_dic/features/sync/port/sync_run_outcome.dart';

void main() {
  final now = DateTime.utc(2026, 8, 10, 12);
  SyncContext context() => SyncContext(
        accountId: 'account-a',
        sessionEpoch: 1,
        reason: 'contract',
        cancellation: CancellationToken(),
      );

  test('public workflow outcome remains a pure four-state value', () {
    expect(SyncRunOutcome.values, [
      SyncRunOutcome.success,
      SyncRunOutcome.retryScheduled,
      SyncRunOutcome.nonRetryableFailure,
      SyncRunOutcome.cancelled,
    ]);
  });

  test('policy implementation stays inside Sync internal', () {
    final portFiles = Directory('lib/features/sync/port')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in portFiles) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('internal/application/policy')),
          reason: file.path);
      expect(source, isNot(contains('SyncExecutionGuard')), reason: file.path);
    }
    final runtime = File(
      'lib/features/sync/internal/application/sync_handler_runtime_adapter.dart',
    ).readAsStringSync();
    expect(runtime, contains('ExponentialBackoff'));
    expect(runtime, contains('SyncErrorClassifier'));
    expect(runtime, contains('SyncExecutionGuard'));
    expect(runtime, isNot(contains('features/my_word/')));
  });

  test('standard handler delegates the MyWord-shaped adapter only to runtime',
      () async {
    final runtime = _RecordingRuntime();
    final adapter = _Adapter();
    final handler =
        AdapterDatasetSyncHandler(adapter: adapter, runtime: runtime);

    final result = await handler.run(context());

    expect(handler.dataset, SyncDataset.myWords);
    expect(runtime.adapter, same(adapter));
    expect(result, isA<DatasetSyncSuccess>());
  });

  test(
      'retryable push failure persists queue retry and leaves checkpoint intact',
      () async {
    final queue = _Queue(leases: [_lease()]);
    final checkpoints = _Checkpoints();
    final adapter = _Adapter(pushError: StateError('network error'));
    final result =
        await _runtime(queue, checkpoints, now).run(context(), adapter);

    expect(result, isA<DatasetSyncFailed>());
    final failed = result as DatasetSyncFailed;
    expect(failed.errorCode, SyncReasonCodes.offline);
    expect(failed.retryable, isTrue);
    expect(failed.cursorUnchanged, isTrue);
    expect(queue.retries, hasLength(1));
    expect(queue.retries.single.nextAttemptAt,
        now.add(const Duration(seconds: 3)));
    expect(queue.acked, isEmpty);
    expect(checkpoints.writes, isEmpty);
  });

  test('successful pull applies rows and commits the greatest checkpoint',
      () async {
    final queue = _Queue(pending: [
      _mutation(fieldMask: const ['word'])
    ]);
    final checkpoints = _Checkpoints();
    final adapter = _Adapter(records: [
      _record('older', now.subtract(const Duration(seconds: 1))),
      _record('newer', now),
    ]);

    final result =
        await _runtime(queue, checkpoints, now).run(context(), adapter);

    expect(result, isA<DatasetSyncSuccess>());
    expect(adapter.applied.map((entry) => entry.record.entityId),
        ['older', 'newer']);
    expect(
      adapter.applied
          .firstWhere((entry) => entry.record.entityId == 'older')
          .skippedFields,
      {'word'},
    );
    expect(checkpoints.writes, hasLength(1));
    expect(checkpoints.writes.single.cursor.documentId, 'newer');
    expect(checkpoints.writes.single.lastSuccessfulAt, now);
  });

  test(
      'session cancellation prevents queue, remote, and checkpoint side effects',
      () async {
    final fence = InMemorySessionFence()..setCurrent('account-a', 2);
    final queue = _Queue(leases: [_lease()]);
    final checkpoints = _Checkpoints();
    final adapter = _Adapter();
    final runtime = SyncHandlerRuntimeAdapter(
      queue: queue,
      checkpoints: checkpoints,
      sessionFence: fence,
      clock: () => now,
    );

    final result = await runtime.run(context(), adapter);

    expect(result, isA<DatasetSyncCancelled>());
    expect((result as DatasetSyncCancelled).reason,
        SyncReasonCodes.sessionChanged);
    expect(queue.leaseCalls, 0);
    expect(adapter.pushCalls, 0);
    expect(checkpoints.writes, isEmpty);
  });
}

SyncHandlerRuntimeAdapter _runtime(
  _Queue queue,
  _Checkpoints checkpoints,
  DateTime now,
) {
  final fence = InMemorySessionFence()..setCurrent('account-a', 1);
  return SyncHandlerRuntimeAdapter(
    queue: queue,
    checkpoints: checkpoints,
    sessionFence: fence,
    retryPolicy: const _FixedRetryPolicy(Duration(seconds: 3)),
    clock: () => now,
  );
}

final class _FixedRetryPolicy implements RetryPolicy {
  const _FixedRetryPolicy(this.delay);
  final Duration delay;
  @override
  Duration delayForAttempt(int attempt) => delay;
}

final class _RecordingRuntime implements SyncHandlerRuntime {
  DatasetSyncAdapter? adapter;
  @override
  Future<DatasetSyncResult> run(
      SyncContext context, DatasetSyncAdapter adapter) async {
    this.adapter = adapter;
    return const DatasetSyncResult.success(pushedCount: 0, pulledCount: 0);
  }
}

final class _Adapter implements DatasetSyncAdapter {
  _Adapter({this.pushError, List<DatasetSyncRecord>? records})
      : records = records ?? const [];
  final Object? pushError;
  final List<DatasetSyncRecord> records;
  int pushCalls = 0;
  final applied = <({DatasetSyncRecord record, Set<String> skippedFields})>[];
  @override
  SyncDataset get dataset => SyncDataset.myWords;
  @override
  Future<RemoteMutationAck> push(RemoteMutationRequest request) async {
    pushCalls++;
    if (pushError != null) throw pushError!;
    return RemoteMutationAck(
      status: RemoteMutationAckStatus.applied,
      remoteRevision: 1,
      lastMutationId: request.mutationId,
      serverUpdatedAt: DateTime.utc(2026),
    );
  }

  @override
  Future<List<DatasetSyncRecord>> pull(
          String accountId, SyncCursor? cursor) async =>
      records;
  @override
  Future<T> transaction<T>(Future<T> Function() action) => action();
  @override
  Future<bool> acknowledge(
          {required SyncMutation mutation,
          required int leasedLocalRevision,
          required String accountId,
          required RemoteMutationAck acknowledgement}) async =>
      true;
  @override
  Future<void> applyRemote(DatasetSyncRecord record,
      {required String accountId, required Set<String> skippedFields}) async {
    applied.add((record: record, skippedFields: Set.of(skippedFields)));
  }
}

final class _Queue implements SyncQueue {
  _Queue({List<MutationLease>? leases, List<SyncMutation>? pending})
      : leases = leases ?? [],
        pending = pending ?? [];
  final List<MutationLease> leases;
  final List<SyncMutation> pending;
  int leaseCalls = 0;
  final acked = <MutationLease>[];
  final retries =
      <({MutationLease lease, String errorCode, DateTime nextAttemptAt})>[];
  @override
  Future<List<MutationLease>> leasePending(
      {required String accountId,
      required SyncDataset dataset,
      required int limit,
      required DateTime now,
      required Duration leaseDuration}) async {
    leaseCalls++;
    return leases;
  }

  @override
  Future<bool> ack(MutationLease lease) async {
    acked.add(lease);
    return true;
  }

  @override
  Future<void> retry(MutationLease lease,
          {required String errorCode, required DateTime nextAttemptAt}) async =>
      retries.add(
          (lease: lease, errorCode: errorCode, nextAttemptAt: nextAttemptAt));
  @override
  Future<void> deadLetter(MutationLease lease,
      {required String errorCode}) async {}
  @override
  Future<int> releaseExpiredLeases(DateTime now) async => 0;
  @override
  Future<DateTime?> earliestPendingAttemptAt(
          {required String accountId}) async =>
      null;
  @override
  Future<List<SyncMutation>> peekPending(
          {required String accountId, required SyncDataset dataset}) async =>
      pending;
}

final class _Checkpoints implements SyncCheckpointStore {
  final writes = <({SyncCursor cursor, DateTime lastSuccessfulAt})>[];
  @override
  Future<SyncCursor?> read(
          {required String accountId, required SyncDataset dataset}) async =>
      null;
  @override
  Future<void> write(
          {required String accountId,
          required SyncDataset dataset,
          required SyncCursor cursor,
          required DateTime lastSuccessfulAt}) async =>
      writes.add((cursor: cursor, lastSuccessfulAt: lastSuccessfulAt));
}

SyncMutation _mutation({List<String> fieldMask = const ['word']}) =>
    SyncMutation(
      mutationId: 'mutation-1',
      accountId: 'account-a',
      dataset: SyncDataset.myWords,
      entityId: 'older',
      operation: SyncMutationOperation.patch,
      payload: const {'word': 'hola'},
      fieldMask: fieldMask,
      localRevision: 1,
      clientUpdatedAt: DateTime.utc(2026),
    );
MutationLease _lease() => MutationLease(
    mutation: _mutation(),
    leaseToken: 'lease',
    leasedLocalRevision: 1,
    leaseUntil: DateTime.utc(2026),
    attemptCount: 0);
DatasetSyncRecord _record(String id, DateTime updatedAt) => DatasetSyncRecord(
    entityId: id,
    updatedAt: updatedAt,
    remoteRevision: 1,
    lastMutationId: null,
    payload: const {});
