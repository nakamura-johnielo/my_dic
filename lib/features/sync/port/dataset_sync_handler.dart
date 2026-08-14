import 'model/dataset_sync_result.dart';
import 'model/sync_context.dart';
import 'sync_dataset.dart';
import 'dataset_sync_gateway.dart';
import 'sync_handler_runtime.dart';

abstract interface class DatasetSyncHandler {
  SyncDataset get dataset;
  Future<DatasetSyncResult> run(SyncContext context);
}

/// Standard handler used by app composition for a dataset-owned adapter.
final class DatasetSyncService implements DatasetSyncHandler {
  const DatasetSyncService({
    required DatasetSyncGateway adapter,
    required SyncHandlerRuntime runtime,
  })  : _adapter = adapter,
        _runtime = runtime;

  final DatasetSyncGateway _adapter;
  final SyncHandlerRuntime _runtime;

  @override
  SyncDataset get dataset => _adapter.dataset;

  @override
  Future<DatasetSyncResult> run(SyncContext context) =>
      _runtime.run(context, _adapter);
}
