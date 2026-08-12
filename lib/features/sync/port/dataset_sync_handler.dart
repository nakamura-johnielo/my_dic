import 'model/dataset_sync_result.dart';
import 'model/sync_context.dart';
import 'sync_dataset.dart';
import 'dataset_sync_adapter.dart';
import 'sync_handler_runtime.dart';

abstract interface class IDatasetSyncHandler {
  SyncDataset get dataset;
  Future<DatasetSyncResult> run(SyncContext context);
}

/// Standard handler used by app composition for a dataset-owned adapter.
final class AdapterDatasetSyncHandler implements IDatasetSyncHandler {
  const AdapterDatasetSyncHandler({
    required IDatasetSyncAdapter adapter,
    required ISyncHandlerRuntime runtime,
  })  : _adapter = adapter,
        _runtime = runtime;

  final IDatasetSyncAdapter _adapter;
  final ISyncHandlerRuntime _runtime;

  @override
  SyncDataset get dataset => _adapter.dataset;

  @override
  Future<DatasetSyncResult> run(SyncContext context) =>
      _runtime.run(context, _adapter);
}
