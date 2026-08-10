import 'dataset_sync_handler.dart';
import 'sync_handler_runtime.dart';
import 'sync_runner.dart';
import 'outbox_writer.dart';
import 'sync_checkpoint_store.dart';
import 'sync_queue.dart';
import 'composition_contract.dart';
import '../internal/composition/sync_composition_factory.dart';

export 'composition_contract.dart';

/// Creates the dataset runtime without exposing Sync internals to the app.
SyncHandlerRuntime createSyncHandlerRuntime(SyncDependencyReader read) =>
    SyncCompositionFactory.createRuntime(read);

SyncQueue createSyncQueue(SyncDependencyReader read) =>
    SyncCompositionFactory.createQueue(read);

SyncCheckpointStore createSyncCheckpointStore(SyncDependencyReader read) =>
    SyncCompositionFactory.createCheckpointStore(read);

OutboxWriter createOutboxWriter(SyncDependencyReader read) =>
    SyncCompositionFactory.createOutboxWriter(read);

/// Creates the public workflow runner for the registered dataset handlers.
SyncRunner createSyncRunner(
  SyncDependencyReader read,
  Iterable<DatasetSyncHandler> handlers,
) =>
    SyncCompositionFactory.createRunner(read, handlers);
