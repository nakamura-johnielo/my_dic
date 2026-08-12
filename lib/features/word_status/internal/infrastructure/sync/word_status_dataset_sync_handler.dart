import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';
import 'word_status_dataset_adapter.dart';

/// Policy-free WordStatus handler facade over the shared Sync runtime.
final class WordStatusDatasetSyncHandler implements IDatasetSyncHandler {
  const WordStatusDatasetSyncHandler({
    required WordStatusDatasetAdapter adapter,
    required ISyncHandlerRuntime runtime,
  })  : _adapter = adapter,
        _runtime = runtime;

  final WordStatusDatasetAdapter _adapter;
  final ISyncHandlerRuntime _runtime;

  @override
  SyncDataset get dataset => _adapter.dataset;

  @override
  Future<DatasetSyncResult> run(SyncContext context) =>
      _runtime.run(context, _adapter);
}
