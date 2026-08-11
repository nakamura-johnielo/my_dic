import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/i_my_word_local_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dto.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/i_my_word_remote_data_source.dart';
import 'package:my_dic/features/sync/port/dataset_sync_adapter.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';
import 'package:my_dic/features/sync/port/model/sync_cursor.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';

// TODO refactor repository的立ち位置
/// MyWord's wire and Drift mapping; durable sync policy lives in Sync runtime.
final class MyWordDatasetSyncAdapter implements DatasetSyncAdapter {
  MyWordDatasetSyncAdapter(
      {required IMyWordLocalDataSource local,
      required IMyWordRemoteDataSource remote})
      : _local = local,
        _remote = remote;

  final IMyWordLocalDataSource _local;
  final IMyWordRemoteDataSource _remote;

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

  @override
  Future<void> applyRemote(DatasetSyncRecord record,
      {required String accountId, required Set<String> skippedFields}) {
    final item = record.payload as MyWordDTO;
    return _local.applyRemoteFields(record.entityId,
        word: skippedFields.contains('word') ? null : item.word,
        contents: skippedFields.contains('contents') ? null : item.contents,
        deletedAt: item.deletedAt?.toIso8601String(),
        editAt: item.updatedAt.toIso8601String(),
        accountId: accountId,
        remoteRevision: record.remoteRevision.toString(),
        lastMutationId: record.lastMutationId);
  }

  DatasetSyncRecord _record(MyWordDTO item) => DatasetSyncRecord(
      entityId: item.myWordId,
      updatedAt: item.updatedAt,
      remoteRevision: item.remoteRevision,
      lastMutationId: item.lastMutationId,
      payload: item);

  DateTime _toDateTime(SyncCursor cursor) =>
      DateTime.fromMicrosecondsSinceEpoch(
          cursor.seconds * 1000000 + cursor.nanoseconds ~/ 1000,
          isUtc: true);
}
