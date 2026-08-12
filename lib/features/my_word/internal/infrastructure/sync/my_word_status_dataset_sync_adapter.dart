import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/i_my_word_status_local_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_dto.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/i_my_word_status_remote_data_source.dart';
import 'package:my_dic/features/sync/port/dataset_sync_adapter.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';
import 'package:my_dic/features/sync/port/model/sync_cursor.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';

// TODO refactor repository的立ち位置
/// MyWordStatus's wire and Drift mapping; durable sync policy lives in Sync runtime.
final class MyWordStatusDatasetSyncAdapter implements IDatasetSyncAdapter {
  MyWordStatusDatasetSyncAdapter(
      {required IMyWordStatusLocalDataSource local,
      required IMyWordStatusRemoteDataSource remote})
      : _local = local,
        _remote = remote;

  final IMyWordStatusLocalDataSource _local;
  final IMyWordStatusRemoteDataSource _remote;

  @override
  SyncDataset get dataset => SyncDataset.myWordStatus;
  @override
  Future<RemoteMutationAck> push(RemoteMutationRequest request) =>
      _remote.patchStatus(request);
  @override
  Future<List<DatasetSyncRecord>> pull(
      String accountId, SyncCursor? cursor) async {
    final since = cursor == null ? MyDateTime.sentinel : _toDateTime(cursor);
    final items = await _remote.getStatusAfter(accountId, since);
    return [
      for (final item in items)
        DatasetSyncRecord(
            entityId: item.myWordId,
            updatedAt: item.updatedAt,
            remoteRevision: item.remoteRevision,
            lastMutationId: item.lastMutationId,
            payload: item)
    ];
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) =>
      _local.runInTransaction(action);
  @override
  Future<bool> acknowledge(
          {required SyncMutation mutation,
          required int leasedLocalRevision,
          required String accountId,
          required RemoteMutationAck acknowledgement}) =>
      _local.acknowledgeRemoteMutation(
          myWordId: mutation.entityId,
          accountId: accountId,
          localRevision: leasedLocalRevision,
          remoteRevision: acknowledgement.remoteRevision.toString(),
          lastMutationId: acknowledgement.lastMutationId);
  @override
  Future<void> applyRemote(DatasetSyncRecord record,
      {required String accountId, required Set<String> skippedFields}) {
    final item = record.payload as MyWordStatusDTO;
    return _local.applyRemoteFields(record.entityId,
        isLearned: skippedFields.contains('isLearned') ? null : item.isLearned,
        isBookmarked:
            skippedFields.contains('isBookmarked') ? null : item.isBookmarked,
        editAt: item.updatedAt.toIso8601String(),
        accountId: accountId,
        remoteRevision: record.remoteRevision.toString(),
        lastMutationId: record.lastMutationId);
  }

  DateTime _toDateTime(SyncCursor cursor) =>
      DateTime.fromMicrosecondsSinceEpoch(
          cursor.seconds * 1000000 + cursor.nanoseconds ~/ 1000,
          isUtc: true);
}
