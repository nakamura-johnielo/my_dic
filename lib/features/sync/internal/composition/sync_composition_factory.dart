import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/internal/application/dataset_handler_registry.dart';
import 'package:my_dic/features/sync/internal/application/policy/dataset_plan.dart';
import 'package:my_dic/features/sync/internal/application/single_flight_coordinator.dart';
import 'package:my_dic/features/sync/internal/application/sync_engine.dart';
import 'package:my_dic/features/sync/internal/application/sync_handler_runtime_service.dart';
import 'package:my_dic/features/sync/internal/application/sync_scheduler.dart';
import 'package:my_dic/features/sync/internal/application/sync_workflow_runner.dart';
import 'package:my_dic/features/sync/internal/infrastructure/persistence/drift/drift_sync_checkpoint_store.dart';
import 'package:my_dic/features/sync/internal/infrastructure/persistence/drift/drift_outbox_writer.dart';
import 'package:my_dic/features/sync/internal/infrastructure/persistence/drift/drift_sync_queue.dart';
import 'package:my_dic/features/sync/internal/infrastructure/scheduling/timer_sync_retry_wakeup.dart';
import 'package:my_dic/features/sync/internal/infrastructure/telemetry/app_logger_sync_telemetry.dart';
import 'package:my_dic/features/sync/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

/// 純粋なポート構成ブリッジの背後にある同一機能の実装です。
final class SyncCompositionFactory {
  const SyncCompositionFactory._();

  static SyncComposition createComposition({
    required DatabaseProvider database,
    required SessionFence sessionFence,
  }) {
    final queue = DriftSyncQueue(database);
    final checkpointStore = DriftSyncCheckpointStore(database);
    return SyncComposition(
      queue: queue,
      checkpointStore: checkpointStore,
      outboxWriter: DriftOutboxWriter(database),
      handlerRuntime: SyncHandlerRuntimeService(
        queue: queue,
        checkpoints: checkpointStore,
        sessionFence: sessionFence,
      ),
    );
  }

  static SyncRunner createRunner({
    required DatabaseProvider database,
    required SessionFence sessionFence,
    required Iterable<DatasetSyncHandler> handlers,
  }) {
    final scheduler = SyncScheduler(
      SyncEngine(
        handlers: DatasetHandlerRegistry(handlers),
        datasetPlan: DatasetPlan.localFirst,
        sessionFence: sessionFence,
        singleFlightCoordinator: SingleFlightCoordinator(),
      ),
      telemetry: AppLoggerSyncTelemetry(),
      queue: DriftSyncQueue(database),
      retryWakeup: TimerSyncRetryWakeup(),
      sessionFence: sessionFence,
    );
    return _ComposedSyncRunner(scheduler);
  }
}

final class _ComposedSyncRunner implements SyncRunner {
  _ComposedSyncRunner(SyncScheduler scheduler)
      : _scheduler = scheduler,
        _runner = SyncWorkflowRunner(scheduler);
  final SyncScheduler _scheduler;
  final SyncWorkflowRunner _runner;
  @override
  Future<SyncRunOutcome> foreground(SyncContext context) =>
      _runner.foreground(context);
  @override
  void cancelRetryForAccount(String accountId) =>
      _runner.cancelRetryForAccount(accountId);
  @override
  void dispose() => _scheduler.dispose();
}
