import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/session_fence_service.dart';
import 'package:my_dic/features/sync/port/composition.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

final syncSessionFenceProvider = Provider<SessionFenceService>(
  (ref) => SessionFenceService(),
);

/// Shared, completed persistence and execution capabilities for Sync.
final syncInfrastructureProvider = Provider<SyncComposition>((ref) {
  return createSyncComposition(
    dependencies: SyncDependencies(
      database: ref.watch(databaseProvider),
      sessionFence: ref.watch(syncSessionFenceProvider),
    ),
  );
});

final driftSyncQueueProvider = Provider<SyncQueue>(
  (ref) => ref.watch(syncInfrastructureProvider).queue,
);

final driftSyncCheckpointStoreProvider = Provider<SyncCheckpointStore>(
  (ref) => ref.watch(syncInfrastructureProvider).checkpointStore,
);

final driftOutboxWriterProvider = Provider<OutboxWriter>(
  (ref) => ref.watch(syncInfrastructureProvider).outboxWriter,
);

final syncHandlerRuntimeProvider = Provider<SyncHandlerRuntime>(
  (ref) => ref.watch(syncInfrastructureProvider).handlerRuntime,
);
