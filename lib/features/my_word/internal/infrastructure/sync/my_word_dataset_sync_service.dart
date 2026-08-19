import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/dataSource/my_word_local_store.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dto.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/my_word_remote_gateway.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

// TODO refactor repository的立ち位置
/// MyWord のワイヤ形式および Drift マッピング。永続的な同期ポリシーは Sync ランタイムにある。
final class MyWordDatasetSyncService implements DatasetSyncGateway {
  MyWordDatasetSyncService(
      {required MyWordLocalDataSource local,
      required MyWordRemoteGateway remote})
      : _local = local,
        _remote = remote;

  final MyWordLocalDataSource _local;
  final MyWordRemoteGateway _remote;

  @override
  SyncDataset get dataset => SyncDataset.myWords;

  @override
  Future<RemoteMutationAck> push(RemoteMutationRequest request) =>
      _remote.patchMyWord(request);

  @override
  Future<List<DatasetSyncRecord>> pull(
      String accountId, SyncCursor? cursor) async {
    final since = cursor == null ? MyDateTime.sentinel : _toDateTime(cursor);
    final items = await _remote.getMyWordsAfter(accountId, since);
    return [for (final item in items) _record(item)];
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
          wordId: mutation.entityId,
          accountId: accountId,
          localRevision: leasedLocalRevision,
          remoteRevision: acknowledgement.remoteRevision.toString(),
          lastMutationId: acknowledgement.lastMutationId);

  Future<void> _applyRemote(MyWordDTO item,
      {required String accountId, required Set<String> skippedFields}) {
    return _local.applyRemoteFields(item.myWordId,
        word: skippedFields.contains('word') ? null : item.word,
        contents: skippedFields.contains('contents') ? null : item.contents,
        deletedAt: item.deletedAt?.toIso8601String(),
        editAt: item.updatedAt.toIso8601String(),
        accountId: accountId,
        remoteRevision: item.remoteRevision.toString(),
        lastMutationId: item.lastMutationId);
  }

  DatasetSyncRecord _record(MyWordDTO item) => DatasetSyncRecord(
      entityId: item.myWordId,
      updatedAt: item.updatedAt,
      remoteRevision: item.remoteRevision,
      lastMutationId: item.lastMutationId,
      applyRemote: ({required accountId, required skippedFields}) =>
          _applyRemote(item,
              accountId: accountId, skippedFields: skippedFields));

  DateTime _toDateTime(SyncCursor cursor) =>
      DateTime.fromMicrosecondsSinceEpoch(
          cursor.seconds * 1000000 + cursor.nanoseconds ~/ 1000,
          isUtc: true);
}
