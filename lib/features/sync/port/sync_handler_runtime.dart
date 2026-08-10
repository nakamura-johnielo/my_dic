import 'dataset_sync_adapter.dart';
import 'model/dataset_sync_result.dart';
import 'model/sync_context.dart';

/// Sync-owned execution capability supplied to the standard dataset handler.
///
/// The implementation owns retry/backoff/classification/guard and all durable
/// queue and checkpoint flow. Feature adapters receive no policy objects.
abstract interface class SyncHandlerRuntime {
  Future<DatasetSyncResult> run(
    SyncContext context,
    DatasetSyncAdapter adapter,
  );
}
