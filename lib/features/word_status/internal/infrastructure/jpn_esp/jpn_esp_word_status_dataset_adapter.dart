import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_local_data_source.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/firebase_jpn_esp_word_status_remote_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/sync/word_status_dataset_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/sync/word_status_sync_record.dart';

final class JpnEspWordStatusDatasetAdapter implements WordStatusDatasetAdapter {
  JpnEspWordStatusDatasetAdapter(
      {required JpnEspWordStatusLocalDataSource local,
      required FirebaseJpnEspWordStatusRemoteStore remote})
      : _local = local,
        _remote = remote;
  final JpnEspWordStatusLocalDataSource _local;
  final FirebaseJpnEspWordStatusRemoteStore _remote;
  @override
  SyncDataset get dataset => SyncDataset.jpnEspWordStatus;
  @override
  Future<RemoteMutationAck> patch(RemoteMutationRequest request) =>
      _remote.patchWordStatus(request);
  @override
  Future<List<WordStatusSyncRecord>> fetchPage(
          String accountId, SyncCursor? cursor) async =>
      (await _remote.fetchPage(accountId, cursor))
          .map((dto) => WordStatusSyncRecord(
              wordId: dto.wordId,
              isLearned: dto.isLearned == 1,
              isBookmarked: dto.isBookmarked == 1,
              hasNote: dto.hasNote == 1,
              updatedAt: dto.updatedAt,
              remoteRevision: dto.remoteRevision,
              lastMutationId: dto.lastMutationId))
          .toList(growable: false);
  @override
  Future<T> transaction<T>(Future<T> Function() action) =>
      _local.runInTransaction(action);
  @override
  Future<bool> acknowledge(
          {required int wordId,
          required String accountId,
          required int localRevision,
          required String remoteRevision,
          required String? lastMutationId}) =>
      _local.acknowledgeRemoteMutation(
          wordId: wordId,
          accountId: accountId,
          localRevision: localRevision,
          remoteRevision: remoteRevision,
          lastMutationId: lastMutationId);
  @override
  Future<void> applyRemote(WordStatusSyncRecord record,
          {required String accountId, required Set<String> skippedFields}) =>
      _local.applyRemoteFields(record.wordId,
          isLearned:
              skippedFields.contains('isLearned') ? null : record.isLearned,
          isBookmarked: skippedFields.contains('isBookmarked')
              ? null
              : record.isBookmarked,
          hasNote: skippedFields.contains('hasNote') ? null : record.hasNote,
          editAt: record.updatedAt.toIso8601String(),
          accountId: accountId,
          remoteRevision: record.remoteRevision.toString(),
          lastMutationId: record.lastMutationId);
}
