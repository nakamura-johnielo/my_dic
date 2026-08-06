import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/sync/application/dataset_handler_registry.dart';
import 'package:my_dic/features/sync/application/in_memory_session_fence.dart';
import 'package:my_dic/features/sync/application/policy/dataset_plan.dart';
import 'package:my_dic/features/sync/application/single_flight_coordinator.dart';
import 'package:my_dic/features/sync/application/sync_engine.dart';
import 'package:my_dic/features/sync/application/sync_scheduler.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_outbox_writer.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_sync_checkpoint_store.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_sync_queue.dart';

/// New local-first infrastructure is composed here, rather than inside a
/// feature or widget. It remains inactive until Local-first 5 introduces the
/// first production DatasetSyncHandler.
final driftSyncQueueProvider = Provider<DriftSyncQueue>((ref) {
  return DriftSyncQueue(ref.watch(databaseProvider));
});

final driftSyncCheckpointStoreProvider = Provider<DriftSyncCheckpointStore>(
  (ref) => DriftSyncCheckpointStore(ref.watch(databaseProvider)),
);

final driftOutboxWriterProvider = Provider<DriftOutboxWriter>(
  (ref) => DriftOutboxWriter(ref.watch(databaseProvider)),
);

final syncSessionFenceProvider = Provider<InMemorySessionFence>(
  (ref) => InMemorySessionFence(),
);

final syncSingleFlightCoordinatorProvider = Provider<SingleFlightCoordinator>(
  (ref) => SingleFlightCoordinator(),
);

final syncDatasetHandlerRegistryProvider = Provider<DatasetHandlerRegistry>(
  (ref) => DatasetHandlerRegistry(const []),
);

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(
    handlers: ref.watch(syncDatasetHandlerRegistryProvider),
    datasetPlan: DatasetPlan.localFirst,
    sessionFence: ref.watch(syncSessionFenceProvider),
    singleFlightCoordinator: ref.watch(syncSingleFlightCoordinatorProvider),
  );
});

final syncSchedulerProvider = Provider<SyncScheduler>(
  (ref) => SyncScheduler(ref.watch(syncEngineProvider)),
);
