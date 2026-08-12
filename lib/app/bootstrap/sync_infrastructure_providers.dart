import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/session_fence_adapter.dart';
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

final driftSyncQueueProvider = Provider<ISyncQueue>((ref) {
  return createSyncQueue(_syncReaderPort(ref));
});

final driftSyncCheckpointStoreProvider = Provider<ISyncCheckpointStore>(
  (ref) => createSyncCheckpointStore(_syncReaderPort(ref)),
);

final driftOutboxWriterProvider = Provider<IOutboxWriter>(
  (ref) => createOutboxWriter(_syncReaderPort(ref)),
);

final syncSessionFenceProvider = Provider<SessionFenceAdapter>(
  (ref) => SessionFenceAdapter(),
);

final syncHandlerRuntimeProvider = Provider<ISyncHandlerRuntime>(
  (ref) => createSyncHandlerRuntime(_syncReaderPort(ref)),
);

SyncDependencyReaderPort _syncReaderPort(Ref ref) {
  T read<T>(Object dependency) => _readSyncDependency<T>(ref, dependency);
  return read;
}
