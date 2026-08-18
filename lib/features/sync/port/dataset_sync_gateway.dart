import 'model/remote_mutation.dart';
import 'model/sync_cursor.dart';
import 'model/sync_mutation.dart';
import 'sync_dataset.dart';

/// Generic remote-item metadata with feature-owned typed apply behavior.
final class DatasetSyncRecord {
  const DatasetSyncRecord({
    required this.entityId,
    required this.updatedAt,
    required this.remoteRevision,
    required this.lastMutationId,
    required Future<void> Function({
      required String accountId,
      required Set<String> skippedFields,
    }) applyRemote,
  }) : _applyRemote = applyRemote;

  final String entityId;
  final DateTime updatedAt;
  final int remoteRevision;
  final String? lastMutationId;
  final Future<void> Function({
    required String accountId,
    required Set<String> skippedFields,
  }) _applyRemote;

  Future<void> applyRemote({
    required String accountId,
    required Set<String> skippedFields,
  }) =>
      _applyRemote(accountId: accountId, skippedFields: skippedFields);
}

/// Raw dataset operations. Sync owns queueing, retries, checkpointing, and
/// session cancellation; a feature owns only its wire/local mapping here.
abstract interface class DatasetSyncGateway {
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
}
