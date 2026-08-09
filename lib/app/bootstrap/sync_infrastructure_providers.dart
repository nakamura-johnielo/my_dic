import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/sync/application/in_memory_session_fence.dart';
import 'package:my_dic/features/sync/application/single_flight_coordinator.dart';
import 'package:my_dic/features/sync/application/sync_execution_guard.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_outbox_writer.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_sync_checkpoint_store.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_sync_queue.dart';

/// Shared persistence and execution primitives used by app composition roots.
///
/// Keeping these outside `sync_composition.dart` lets feature composition
/// construct dataset handlers without importing the registry.
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

final syncExecutionGuardProvider = Provider<SyncExecutionGuard>(
  (ref) => SyncExecutionGuard(ref.watch(syncSessionFenceProvider)),
);
