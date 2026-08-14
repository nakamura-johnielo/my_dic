import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'word_status_dataset_sync_service.dart';

/// Policy-free WordStatus handler facade over the shared Sync runtime.
final class WordStatusDatasetSyncHandler implements DatasetSyncHandler {
  const WordStatusDatasetSyncHandler({
    required WordStatusDatasetSyncService adapter,
    required SyncHandlerRuntime runtime,
  })  : _adapter = adapter,
        _runtime = runtime;

  final WordStatusDatasetSyncService _adapter;
  final SyncHandlerRuntime _runtime;

  @override
  SyncDataset get dataset => _adapter.dataset;

  @override
  Future<DatasetSyncResult> run(SyncContext context) =>
      _runtime.run(context, _adapter);
}
