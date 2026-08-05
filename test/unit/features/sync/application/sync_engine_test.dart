import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/cancellation_token.dart';
import 'package:my_dic/features/sync/application/dataset_handler_registry.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/application/port/session_fence.dart';
import 'package:my_dic/features/sync/application/policy/dataset_plan.dart';
import 'package:my_dic/features/sync/application/single_flight_coordinator.dart';
import 'package:my_dic/features/sync/application/in_memory_session_fence.dart';
import 'package:my_dic/features/sync/application/sync_engine.dart';

class _Fence implements SessionFence {
  @override
  bool isCurrent({required String accountId, required int sessionEpoch}) =>
      true;
}

class _Handler implements DatasetSyncHandler {
  _Handler(this.dataset,
      {this.result =
          const DatasetSyncResult.success(pushedCount: 1, pulledCount: 2)});
  @override
  final SyncDataset dataset;
  int calls = 0;
  final DatasetSyncResult result;
  @override
  Future<DatasetSyncResult> run(SyncContext context) async {
    calls++;
    return result;
  }
}

class _BlockingHandler implements DatasetSyncHandler {
  @override
  final SyncDataset dataset = SyncDataset.myWords;
  final started = Completer<void>();
  final release = Completer<void>();
  int calls = 0;
  @override
  Future<DatasetSyncResult> run(SyncContext context) async {
    calls++;
    if (calls == 1) {
      started.complete();
      await release.future;
    }
    return const DatasetSyncResult.success(pushedCount: 0, pulledCount: 0);
  }
}

void main() {
  test('runs handlers in the declared dataset order', () async {
    final first = _Handler(SyncDataset.myWords);
    final second = _Handler(SyncDataset.userProfile);
    final engine = SyncEngine(
      handlers: DatasetHandlerRegistry([first, second]),
      datasetPlan:
          const DatasetPlan([SyncDataset.myWords, SyncDataset.userProfile]),
      sessionFence: _Fence(),
      singleFlightCoordinator: SingleFlightCoordinator(),
    );

    final report = await engine.runOnce(SyncContext(
        accountId: 'a',
        sessionEpoch: 1,
        reason: 'test',
        cancellation: CancellationToken()));

    expect(first.calls, 1);
    expect(second.calls, 1);
    expect(report.datasetResults.keys,
        [SyncDataset.myWords, SyncDataset.userProfile]);
  });

  test('cancellation reports every remaining dataset as cancelled', () async {
    final handler = _Handler(SyncDataset.myWords);
    final token = CancellationToken()..cancel('sign out');
    final engine = SyncEngine(
      handlers: DatasetHandlerRegistry([handler]),
      datasetPlan: const DatasetPlan([SyncDataset.myWords]),
      sessionFence: _Fence(),
      singleFlightCoordinator: SingleFlightCoordinator(),
    );
    final report = await engine.runOnce(SyncContext(
        accountId: 'a', sessionEpoch: 1, reason: 'test', cancellation: token));
    expect(handler.calls, 0);
    expect(report.datasetResults[SyncDataset.myWords],
        isA<DatasetSyncCancelled>());
  });

  test('an account epoch change cancels the report after a handler returns',
      () async {
    final fence = InMemorySessionFence()..setCurrent('a', 1);
    final handler = _Handler(SyncDataset.myWords);
    final engine = SyncEngine(
      handlers: DatasetHandlerRegistry([handler]),
      datasetPlan: const DatasetPlan([SyncDataset.myWords]),
      sessionFence: fence,
      singleFlightCoordinator: SingleFlightCoordinator(),
    );
    fence.setCurrent('a', 2);
    final report = await engine.runOnce(SyncContext(
        accountId: 'a',
        sessionEpoch: 1,
        reason: 'test',
        cancellation: CancellationToken()));
    expect(handler.calls, 0);
    expect(report.datasetResults[SyncDataset.myWords],
        isA<DatasetSyncCancelled>());
  });

  test(
      'skips a child after its dependency fails and continues an independent dataset',
      () async {
    final parent = _Handler(SyncDataset.myWords,
        result: const DatasetSyncResult.failed(
            errorCode: 'remote', retryable: true, cursorUnchanged: true));
    final child = _Handler(SyncDataset.myWordStatus);
    final independent = _Handler(SyncDataset.userProfile);
    final engine = SyncEngine(
      handlers: DatasetHandlerRegistry([parent, child, independent]),
      datasetPlan: const DatasetPlan(
        [
          SyncDataset.myWordStatus,
          SyncDataset.userProfile,
          SyncDataset.myWords
        ],
        dependencies: {
          SyncDataset.myWordStatus: {SyncDataset.myWords}
        },
      ),
      sessionFence: _Fence(),
      singleFlightCoordinator: SingleFlightCoordinator(),
    );
    final report = await engine.runOnce(SyncContext(
        accountId: 'a',
        sessionEpoch: 1,
        reason: 'test',
        cancellation: CancellationToken()));
    expect(report.datasetResults[SyncDataset.myWordStatus],
        isA<DatasetSyncSkipped>());
    expect(child.calls, 0);
    expect(independent.calls, 1);
  });

  test('rejects dependency cycles before running handlers', () {
    const plan = DatasetPlan(
      [SyncDataset.myWords, SyncDataset.myWordStatus],
      dependencies: {
        SyncDataset.myWords: {SyncDataset.myWordStatus},
        SyncDataset.myWordStatus: {SyncDataset.myWords},
      },
    );
    expect(plan.orderedDatasets, throwsStateError);
  });

  test('coalesces triggers during a cycle into at most one rerun', () async {
    final handler = _BlockingHandler();
    final engine = SyncEngine(
      handlers: DatasetHandlerRegistry([handler]),
      datasetPlan: const DatasetPlan([SyncDataset.myWords]),
      sessionFence: _Fence(),
      singleFlightCoordinator: SingleFlightCoordinator(),
    );
    SyncContext context() => SyncContext(
        accountId: 'a',
        sessionEpoch: 1,
        reason: 'test',
        cancellation: CancellationToken());
    final first = engine.runOnce(context());
    await handler.started.future;
    await engine.runOnce(context());
    await engine.runOnce(context());
    handler.release.complete();
    await first;
    expect(handler.calls, 2);
  });
}
