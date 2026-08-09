import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/sync_infrastructure_providers.dart';
import 'package:my_dic/app/bootstrap/word_status_composition.dart';
import 'package:my_dic/features/my_word/di/data_di.dart';
import 'package:my_dic/features/sync/application/dataset_handler_registry.dart';
import 'package:my_dic/features/sync/application/policy/dataset_plan.dart';
import 'package:my_dic/features/sync/application/sync_engine.dart';
import 'package:my_dic/features/sync/application/sync_scheduler.dart';
import 'package:my_dic/features/sync/infrastructure/scheduling/timer_sync_retry_wakeup.dart';
import 'package:my_dic/features/sync/infrastructure/telemetry/app_logger_sync_telemetry.dart';
import 'package:my_dic/features/user/di/data_di.dart';

export 'sync_infrastructure_providers.dart';

final syncDatasetHandlerRegistryProvider = Provider<DatasetHandlerRegistry>(
  (ref) => DatasetHandlerRegistry([
    ...ref.watch(wordStatusDatasetSyncHandlersProvider),
    ref.watch(myWordSyncHandlerProvider),
    ref.watch(myWordStatusSyncHandlerProvider),
    ref.watch(userProfileSyncHandlerProvider),
  ]),
);

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(
    handlers: ref.watch(syncDatasetHandlerRegistryProvider),
    datasetPlan: DatasetPlan.localFirst,
    sessionFence: ref.watch(syncSessionFenceProvider),
    singleFlightCoordinator: ref.watch(syncSingleFlightCoordinatorProvider),
  );
});

final syncRetryWakeupProvider = Provider<TimerSyncRetryWakeup>((ref) {
  final wakeup = TimerSyncRetryWakeup();
  ref.onDispose(wakeup.dispose);
  return wakeup;
});

final syncSchedulerProvider = Provider<SyncScheduler>(
  (ref) {
    final scheduler = SyncScheduler(
      ref.watch(syncEngineProvider),
      telemetry: AppLoggerSyncTelemetry(),
      queue: ref.watch(driftSyncQueueProvider),
      retryWakeup: ref.watch(syncRetryWakeupProvider),
      sessionFence: ref.watch(syncSessionFenceProvider),
    );
    ref.onDispose(scheduler.dispose);
    return scheduler;
  },
);
