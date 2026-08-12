import 'package:my_dic/features/sync/port/dataset_sync_adapter.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';
import 'package:my_dic/features/sync/port/model/sync_cursor.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'word_status_sync_record.dart';

/// Direction-specific WordStatus mapping for the shared Sync runtime.
///
/// The Sync feature owns queue, retry, checkpoint, and cancellation policy.
/// This adapter only translates WordStatus remote and local representations.
abstract class WordStatusDatasetAdapter implements IDatasetSyncAdapter {
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
  @override
  Future<void> applyRemote(
    DatasetSyncRecord record, {
    required String accountId,
    required Set<String> skippedFields,
  }) =>
      applyWordStatusRemote(
        record.payload as WordStatusSyncRecord,
        accountId: accountId,
        skippedFields: skippedFields,
      );
  Future<void> applyWordStatusRemote(
    WordStatusSyncRecord record, {
    required String accountId,
    required Set<String> skippedFields,
  });

  static DatasetSyncRecord _toDatasetRecord(WordStatusSyncRecord record) =>
      DatasetSyncRecord(
        entityId: record.wordId.toString(),
        updatedAt: record.updatedAt,
        remoteRevision: record.remoteRevision,
        lastMutationId: record.lastMutationId,
        payload: record,
      );
}
