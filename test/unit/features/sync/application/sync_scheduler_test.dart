import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/cancellation_token.dart';
import 'package:my_dic/features/sync/application/dataset_handler_registry.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/model/sync_report.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/application/port/session_fence.dart';
import 'package:my_dic/features/sync/application/port/sync_telemetry.dart';
import 'package:my_dic/features/sync/application/port/sync_retry_wakeup.dart';
import 'package:my_dic/features/sync/application/policy/dataset_plan.dart';
import 'package:my_dic/features/sync/application/single_flight_coordinator.dart';
import 'package:my_dic/features/sync/application/sync_engine.dart';
import 'package:my_dic/features/sync/application/sync_scheduler.dart';
import 'package:my_dic/features/sync/application/report/sync_reason_codes.dart';
import '../../../../helpers/sync/fake_sync_queue.dart';

class _CurrentFence implements SessionFence {
  @override
  bool isCurrent({required String accountId, required int sessionEpoch}) =>
      true;
}

class _SuccessHandler implements DatasetSyncHandler {
  @override
  SyncDataset get dataset => SyncDataset.myWords;

  @override
  Future<DatasetSyncResult> run(SyncContext context) async =>
      const DatasetSyncResult.success(pushedCount: 3, pulledCount: 5);
}

class _ThrowingTelemetry implements SyncTelemetry {
  int calls = 0;

  @override
  Future<void> recordCycleCompleted({
    required String trigger,
    required SyncReport report,
  }) async {
    calls++;
    throw StateError('telemetry failure must stay isolated');
  }
}

class _RetryHandler implements DatasetSyncHandler {
  _RetryHandler(this.result);
  DatasetSyncResult result;
  final List<SyncContext> contexts = [];
  @override
  SyncDataset get dataset => SyncDataset.myWords;
  @override
  Future<DatasetSyncResult> run(SyncContext context) async {
    contexts.add(context);
    return result;
  }
}

class _FakeWakeup implements SyncRetryWakeup {
  final Map<String, ({DateTime dueAt, void Function() callback})> pending = {};
  bool disposed = false;
  int armCalls = 0;
  @override
  void arm(
      {required String accountId,
      required DateTime dueAt,
      required void Function() onDue}) {
    armCalls++;
    pending[accountId] = (dueAt: dueAt.toUtc(), callback: onDue);
  }

  void fire(String accountId) => pending.remove(accountId)?.callback();
  @override
  void cancel(String accountId) => pending.remove(accountId);
  @override
  void dispose() {
    disposed = true;
    pending.clear();
  }
}

void main() {
  test('notifies telemetry once and returns the unchanged successful report',
      () async {
    final telemetry = FakeSyncTelemetry();
    final scheduler = SyncScheduler(_engine(), telemetry: telemetry);
    final context = SyncContext(
      accountId: 'account-private',
      sessionEpoch: 7,
      reason: 'manual',
      cancellation: CancellationToken(),
    );

    final report = await scheduler.foreground(context);

    expect(telemetry.calls, hasLength(1));
    expect(telemetry.calls.single.trigger, 'manual');
    expect(identical(telemetry.calls.single.report, report), isTrue);
    expect(
        report.datasetResults[SyncDataset.myWords], isA<DatasetSyncSuccess>());
  });

  test('swallows telemetry errors without altering the engine report',
      () async {
    final telemetry = _ThrowingTelemetry();
    final report = await SyncScheduler(_engine(), telemetry: telemetry)
        .foreground(SyncContext(
      accountId: 'account-private',
      sessionEpoch: 7,
      reason: 'manual',
      cancellation: CancellationToken(),
    ));

    expect(telemetry.calls, 1);
    expect(
        report.datasetResults[SyncDataset.myWords], isA<DatasetSyncSuccess>());
  });

  test('wakes only at the queue due time with retry_due', () async {
    final queue = FakeSyncQueue();
    final wakeup = _FakeWakeup();
    final handler = _RetryHandler(const DatasetSyncResult.failed(
        errorCode: 'network', retryable: true, cursorUnchanged: true));
    var now = DateTime.utc(2026);
    final dueAt = now.add(const Duration(minutes: 1));
    final mutation = _retryMutation();
    queue.enqueue(mutation);
    queue.nextAttemptAt[mutation.mutationId] = dueAt;
    final scheduler = SyncScheduler(_engineWith(handler),
        queue: queue, retryWakeup: wakeup, clock: () => now);
    final context = SyncContext(
        accountId: 'account-a',
        sessionEpoch: 1,
        reason: 'manual',
        cancellation: CancellationToken());

    await scheduler.foreground(context);
    expect(wakeup.pending['account-a']!.dueAt, dueAt);
    now = dueAt.subtract(const Duration(milliseconds: 1));
    wakeup.fire('account-a');
    expect(handler.contexts, hasLength(1));
    now = dueAt;
    wakeup.fire('account-a');
    await Future<void>.delayed(Duration.zero);
    expect(handler.contexts, hasLength(2));
    expect(handler.contexts.last.reason, SyncReasonCodes.retryDue);
  });

  test('does not arm without a retryable failure and cancels on disposal',
      () async {
    final wakeup = _FakeWakeup();
    final scheduler =
        SyncScheduler(_engine(), queue: FakeSyncQueue(), retryWakeup: wakeup);
    await scheduler.foreground(SyncContext(
        accountId: 'account-a',
        sessionEpoch: 1,
        reason: 'manual',
        cancellation: CancellationToken()));
    expect(wakeup.armCalls, 0);
    scheduler.dispose();
    expect(wakeup.disposed, isTrue);
  });

  test('does not arm for non-retryable or cancelled reports', () async {
    final wakeup = _FakeWakeup();
    final handler = _RetryHandler(const DatasetSyncResult.failed(
      errorCode: 'invalid',
      retryable: false,
      cursorUnchanged: true,
    ));
    final scheduler = SyncScheduler(_engineWith(handler),
        queue: FakeSyncQueue(), retryWakeup: wakeup);
    final context = SyncContext(
        accountId: 'account-a',
        sessionEpoch: 1,
        reason: 'manual',
        cancellation: CancellationToken());
    await scheduler.foreground(context);
    handler.result = const DatasetSyncResult.cancelled('caller_cancelled');
    await scheduler.foreground(context);
    expect(wakeup.armCalls, 0);
  });
}

SyncEngine _engine() => SyncEngine(
      handlers: DatasetHandlerRegistry([_SuccessHandler()]),
      datasetPlan: const DatasetPlan([SyncDataset.myWords]),
      sessionFence: _CurrentFence(),
      singleFlightCoordinator: SingleFlightCoordinator(),
    );

SyncEngine _engineWith(DatasetSyncHandler handler) => SyncEngine(
      handlers: DatasetHandlerRegistry([handler]),
      datasetPlan: const DatasetPlan([SyncDataset.myWords]),
      sessionFence: _CurrentFence(),
      singleFlightCoordinator: SingleFlightCoordinator(),
    );

SyncMutation _retryMutation() => SyncMutation(
    mutationId: 'retry-mutation',
    accountId: 'account-a',
    dataset: SyncDataset.myWords,
    entityId: 'item',
    operation: SyncMutationOperation.upsert,
    payload: const {},
    fieldMask: const [],
    localRevision: 1,
    clientUpdatedAt: DateTime.utc(2026));
