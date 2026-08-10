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
SyncHandlerRuntime createSyncHandlerRuntime(SyncDependencyReaderPort read) =>
    SyncCompositionFactory.createRuntime(read);

SyncQueue createSyncQueue(SyncDependencyReaderPort read) =>
    SyncCompositionFactory.createQueue(read);

SyncCheckpointStore createSyncCheckpointStore(SyncDependencyReaderPort read) =>
    SyncCompositionFactory.createCheckpointStore(read);

OutboxWriter createOutboxWriter(SyncDependencyReaderPort read) =>
    SyncCompositionFactory.createOutboxWriter(read);

/// Creates the public workflow runner for the registered dataset handlers.
SyncRunner createSyncRunner(
  SyncDependencyReaderPort read,
  Iterable<DatasetSyncHandler> handlers,
) =>
    SyncCompositionFactory.createRunner(read, handlers);
