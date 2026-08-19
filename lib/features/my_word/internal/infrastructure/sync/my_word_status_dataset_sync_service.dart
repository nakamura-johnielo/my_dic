import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/dataSource/my_word_status_local_store.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_dto.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/my_word_status_remote_gateway.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

// TODO refactor repository的立ち位置
/// MyWordStatus のワイヤ形式および Drift マッピング。永続的な同期ポリシーは Sync ランタイムにある。
final class MyWordStatusDatasetSyncService implements DatasetSyncGateway {
  MyWordStatusDatasetSyncService(
      {required IMyWordStatusLocalDataSource local,
      required MyWordStatusRemoteGateway remote})
      : _local = local,
        _remote = remote;

  final IMyWordStatusLocalDataSource _local;
  final MyWordStatusRemoteGateway _remote;

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
            applyRemote: ({required accountId, required skippedFields}) =>
                _applyRemote(item,
                    accountId: accountId, skippedFields: skippedFields))
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
  Future<void> _applyRemote(MyWordStatusDTO item,
      {required String accountId, required Set<String> skippedFields}) {
    return _local.applyRemoteFields(item.myWordId,
        isLearned: skippedFields.contains('isLearned') ? null : item.isLearned,
        isBookmarked:
            skippedFields.contains('isBookmarked') ? null : item.isBookmarked,
        editAt: item.updatedAt.toIso8601String(),
        accountId: accountId,
        remoteRevision: item.remoteRevision.toString(),
        lastMutationId: item.lastMutationId);
  }

  DateTime _toDateTime(SyncCursor cursor) =>
      DateTime.fromMicrosecondsSinceEpoch(
          cursor.seconds * 1000000 + cursor.nanoseconds ~/ 1000,
          isUtc: true);
}
