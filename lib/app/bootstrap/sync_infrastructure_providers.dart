import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/app/workflows/session_lifecycle/session_fence_adapter.dart';
import 'package:my_dic/features/sync/port/composition.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/port/sync_checkpoint_store.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';
import 'package:my_dic/features/sync/port/sync_queue.dart';

/// Shared persistence and execution primitives used by app composition roots.
///
/// Keeping these outside `sync_composition.dart` lets feature composition
/// construct dataset handlers without importing the registry.
T _readSyncDependency<T>(Ref ref, Object dependency) {
  if (identical(dependency, SyncCompositionDependencies.database)) {
    return ref.watch(databaseProvider) as T;
  }
  if (identical(dependency, SyncCompositionDependencies.sessionFence)) {
    return ref.watch(syncSessionFenceProvider) as T;
  }
  throw ArgumentError.value(dependency, 'dependency');
}

final driftSyncQueueProvider = Provider<SyncQueue>((ref) {
  return createSyncQueue(_syncReader(ref));
});

final driftSyncCheckpointStoreProvider = Provider<SyncCheckpointStore>(
  (ref) => createSyncCheckpointStore(_syncReader(ref)),
);

final driftOutboxWriterProvider = Provider<OutboxWriter>(
  (ref) => createOutboxWriter(_syncReader(ref)),
);

final syncSessionFenceProvider = Provider<SessionFenceAdapter>(
  (ref) => SessionFenceAdapter(),
);

final syncHandlerRuntimeProvider = Provider<SyncHandlerRuntime>(
  (ref) => createSyncHandlerRuntime(_syncReader(ref)),
);

SyncDependencyReader _syncReader(Ref ref) {
  T read<T>(Object dependency) => _readSyncDependency<T>(ref, dependency);
  return read;
}
