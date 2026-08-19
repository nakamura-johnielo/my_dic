import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'word_status_sync_record.dart';

/// 共通 Sync ランタイム用の方向固有 WordStatus マッピングです。
///
/// Sync 機能がキュー、再試行、チェックポイント、キャンセルポリシーを所有します。
/// このアダプターは WordStatus のリモート表現とローカル表現を変換するだけです。
abstract class WordStatusDatasetSyncService implements DatasetSyncGateway {
  @override
  SyncDataset get dataset;

  @override
  Future<RemoteMutationAck> push(RemoteMutationRequest request);
  Future<List<WordStatusSyncRecord>> fetchWordStatusPage(
    String accountId,
    SyncCursor? cursor,
  );
  @override
  Future<List<DatasetSyncRecord>> pull(
          String accountId, SyncCursor? cursor) async =>
      (await fetchWordStatusPage(accountId, cursor))
          .map(_toDatasetRecord)
          .toList(growable: false);
  @override
  Future<T> transaction<T>(Future<T> Function() action);
  Future<bool> acknowledgeWordStatus({
    required int wordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  });
  @override
  Future<bool> acknowledge({
    required SyncMutation mutation,
    required int leasedLocalRevision,
    required String accountId,
    required RemoteMutationAck acknowledgement,
  }) =>
      acknowledgeWordStatus(
        wordId: int.parse(mutation.entityId),
        accountId: accountId,
        localRevision: leasedLocalRevision,
        remoteRevision: acknowledgement.remoteRevision.toString(),
        lastMutationId: acknowledgement.lastMutationId,
      );
  Future<void> applyWordStatusRemote(
    WordStatusSyncRecord record, {
    required String accountId,
    required Set<String> skippedFields,
  });

  DatasetSyncRecord _toDatasetRecord(WordStatusSyncRecord record) =>
      DatasetSyncRecord(
        entityId: record.wordId.toString(),
        updatedAt: record.updatedAt,
        remoteRevision: record.remoteRevision,
        lastMutationId: record.lastMutationId,
        applyRemote: ({required accountId, required skippedFields}) =>
            applyWordStatusRemote(record,
                accountId: accountId, skippedFields: skippedFields),
      );
}
