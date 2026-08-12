import 'model/remote_mutation.dart';
import 'model/sync_cursor.dart';
import 'model/sync_mutation.dart';
import 'sync_dataset.dart';

/// Dataset-specific remote item whose payload remains owned by its feature.
final class DatasetSyncRecord {
  const DatasetSyncRecord({
    required this.entityId,
    required this.updatedAt,
    required this.remoteRevision,
    required this.lastMutationId,
    required this.payload,
  });

  final String entityId;
  final DateTime updatedAt;
  final int remoteRevision;
  final String? lastMutationId;
  final Object payload;
}

/// Raw dataset operations. Sync owns queueing, retries, checkpointing, and
/// session cancellation; a feature owns only its wire/local mapping here.
abstract interface class IDatasetSyncAdapter {
  SyncDataset get dataset;

  Future<RemoteMutationAck> push(RemoteMutationRequest request);
  Future<List<DatasetSyncRecord>> pull(String accountId, SyncCursor? cursor);
  Future<T> transaction<T>(Future<T> Function() action);
  Future<bool> acknowledge({
    required SyncMutation mutation,
    required int leasedLocalRevision,
    required String accountId,
    required RemoteMutationAck acknowledgement,
  });
  Future<void> applyRemote(
    DatasetSyncRecord record, {
    required String accountId,
    required Set<String> skippedFields,
  });
}
