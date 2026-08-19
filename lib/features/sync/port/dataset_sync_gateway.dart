import 'model/remote_mutation.dart';
import 'model/sync_cursor.dart';
import 'model/sync_mutation.dart';
import 'sync_dataset.dart';

/// 機能所有の型付き適用動作を持つ、汎用リモート項目メタデータです。
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

/// 生のデータセット操作です。Sync はキューイング、再試行、チェックポイント、セッション
/// キャンセルを所有し、機能はここで通信／ローカルマッピングのみを所有します。
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
