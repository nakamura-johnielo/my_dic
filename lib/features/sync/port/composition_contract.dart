import 'outbox_writer.dart';
import 'sync_checkpoint_store.dart';
import 'sync_handler_runtime.dart';
import 'sync_queue.dart';

/// Completed Sync infrastructure for one application scope.
///
/// App composition owns this bundle's lifetime. Dataset registries consume
/// only completed handlers and never construct these capabilities themselves.
final class SyncComposition {
  const SyncComposition({
    required this.queue,
    required this.checkpointStore,
    required this.outboxWriter,
    required this.handlerRuntime,
  });

  final SyncQueue queue;
  final SyncCheckpointStore checkpointStore;
  final OutboxWriter outboxWriter;
  final SyncHandlerRuntime handlerRuntime;
}
