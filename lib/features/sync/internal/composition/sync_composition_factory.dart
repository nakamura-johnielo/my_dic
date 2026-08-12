import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/internal/application/dataset_handler_registry.dart';
import 'package:my_dic/features/sync/internal/application/policy/dataset_plan.dart';
import 'package:my_dic/features/sync/internal/application/single_flight_coordinator.dart';
import 'package:my_dic/features/sync/internal/application/sync_engine.dart';
import 'package:my_dic/features/sync/internal/application/sync_handler_runtime_adapter.dart';
import 'package:my_dic/features/sync/internal/application/sync_scheduler.dart';
import 'package:my_dic/features/sync/internal/application/sync_workflow_runner.dart';
import 'package:my_dic/features/sync/internal/infrastructure/persistence/drift/drift_sync_checkpoint_store.dart';
import 'package:my_dic/features/sync/internal/infrastructure/persistence/drift/drift_outbox_writer.dart';
import 'package:my_dic/features/sync/internal/infrastructure/persistence/drift/drift_sync_queue.dart';
import 'package:my_dic/features/sync/internal/infrastructure/scheduling/timer_sync_retry_wakeup.dart';
import 'package:my_dic/features/sync/internal/infrastructure/telemetry/app_logger_sync_telemetry.dart';
import 'package:my_dic/features/sync/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/port/session_fence.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';
import 'package:my_dic/features/sync/port/sync_checkpoint_store.dart';
import 'package:my_dic/features/sync/port/sync_queue.dart';
import 'package:my_dic/features/sync/port/sync_runner.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/sync_run_outcome.dart';

/// Same-feature implementation behind the pure port composition bridge.
final class SyncCompositionFactory {
  const SyncCompositionFactory._();

  static SyncHandlerRuntime createRuntime(SyncDependencyReaderPort read) {
    final database =
        read<DatabaseProvider>(SyncCompositionDependencies.database);
    final fence = read<SessionFence>(SyncCompositionDependencies.sessionFence);
    return SyncHandlerRuntimeAdapter(
      queue: DriftSyncQueue(database),
      checkpoints: DriftSyncCheckpointStore(database),
      sessionFence: fence,
    );
  }

  static SyncQueue createQueue(SyncDependencyReaderPort read) => DriftSyncQueue(
      read<DatabaseProvider>(SyncCompositionDependencies.database));

  static SyncCheckpointStore createCheckpointStore(
          SyncDependencyReaderPort read) =>
      DriftSyncCheckpointStore(
          read<DatabaseProvider>(SyncCompositionDependencies.database));

  static OutboxWriter createOutboxWriter(SyncDependencyReaderPort read) =>
      DriftOutboxWriter(
          read<DatabaseProvider>(SyncCompositionDependencies.database));

  static SyncRunner createRunner(
    SyncDependencyReaderPort read,
    Iterable<DatasetSyncHandler> handlers,
  ) {
    final database =
        read<DatabaseProvider>(SyncCompositionDependencies.database);
    final fence = read<SessionFence>(SyncCompositionDependencies.sessionFence);
    final scheduler = SyncScheduler(
      SyncEngine(
        handlers: DatasetHandlerRegistry(handlers),
        datasetPlan: DatasetPlan.localFirst,
        sessionFence: fence,
        singleFlightCoordinator: SingleFlightCoordinator(),
      ),
      telemetry: AppLoggerSyncTelemetry(),
      queue: DriftSyncQueue(database),
      retryWakeup: TimerSyncRetryWakeup(),
      sessionFence: fence,
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
