import 'package:my_dic/features/sync/port/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/model/sync_report.dart';
import 'package:my_dic/features/sync/port/session_fence.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/sync/port/sync_reason_codes.dart';
import 'dataset_handler_registry.dart';
import 'policy/dataset_plan.dart';
import 'single_flight_coordinator.dart';

class SyncEngine {
  SyncEngine(
      {required DatasetHandlerRegistry handlers,
      required this.datasetPlan,
      required this.sessionFence,
      required this.singleFlightCoordinator,
      DateTime Function()? clock})
      : _handlers = handlers,
        _clock = clock ?? DateTime.now;
  final DatasetHandlerRegistry _handlers;
  final DatasetPlan datasetPlan;
  final SessionFence sessionFence;
  final SingleFlightCoordinator singleFlightCoordinator;
  final DateTime Function() _clock;

  Future<SyncReport> runOnce(SyncContext context) async {
    final startedAt = _clock();
    final results = <SyncDataset, DatasetSyncResult>{};
    final orderedDatasets = datasetPlan.orderedDatasets();
    if (!singleFlightCoordinator.tryAcquire(context.accountId)) {
      return SyncReport(
          accountId: context.accountId,
          startedAt: startedAt,
          finishedAt: _clock(),
          datasetResults: {
            for (final d in orderedDatasets)
              d: const DatasetSyncResult.skipped(
                  SyncReasonCodes.syncAlreadyRunning)
          });
    }
    try {
      var cycle = 0;
      var shouldRerun = false;
      do {
        if (cycle > 0) results.clear();
        for (final dataset in orderedDatasets) {
          if (context.cancellation.isCancelled ||
              !sessionFence.isCurrent(
                  accountId: context.accountId,
                  sessionEpoch: context.sessionEpoch)) {
            results[dataset] = DatasetSyncResult.cancelled(
                sessionFence.isCurrent(
                        accountId: context.accountId,
                        sessionEpoch: context.sessionEpoch)
                    ? SyncReasonCodes.callerCancelled
                    : SyncReasonCodes.sessionChanged);
            continue;
          }
          final blocked =
              (datasetPlan.dependencies[dataset] ?? const {}).any((parent) {
            final result = results[parent];
            return result is DatasetSyncFailed ||
                result is DatasetSyncCancelled ||
                result is DatasetSyncSkipped;
          });
          if (blocked) {
            results[dataset] = const DatasetSyncResult.skipped(
                SyncReasonCodes.dependencyFailed);
            continue;
          }
          final handler = _handlers[dataset];
          if (handler == null) {
            results[dataset] = const DatasetSyncResult.skipped(
                SyncReasonCodes.handlerUnavailable);
            continue;
          }
          try {
            final result = await handler.run(context);
            // ハンドラーは同じキャンセルトークンを受け取り、ローカルの各チェックポイント／確認前に
            // 検査する必要があります。この第 2 の境界はレポートを保護し、アカウント切替後の
            // 後続データセットを防止します。
            if (!sessionFence.isCurrent(
                accountId: context.accountId,
                sessionEpoch: context.sessionEpoch)) {
              context.cancellation.cancel(SyncReasonCodes.sessionChanged);
              results[dataset] = const DatasetSyncResult.cancelled(
                  SyncReasonCodes.sessionChanged);
            } else {
              results[dataset] = result;
            }
          } catch (_) {
            results[dataset] = const DatasetSyncResult.failed(
                errorCode: SyncReasonCodes.handlerException,
                retryable: true,
                cursorUnchanged: true);
          }
        }
        cycle++;
        shouldRerun = cycle == 1 &&
            singleFlightCoordinator.takeRerunRequest(context.accountId);
      } while (shouldRerun);
    } finally {
      singleFlightCoordinator.release(context.accountId);
    }
    return SyncReport(
        accountId: context.accountId,
        startedAt: startedAt,
        finishedAt: _clock(),
        datasetResults: results);
  }
}
