import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_local_data_source.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/firebase_esp_jpn_word_status_remote_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/sync/word_status_dataset_sync_service.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/sync/word_status_sync_record.dart';

final class EspJpnWordStatusDatasetSyncService extends WordStatusDatasetSyncService {
  EspJpnWordStatusDatasetSyncService(
      {required EspJpnWordStatusLocalDataSource local,
      required FirebaseEspJpnWordStatusRemoteStore remote})
      : _local = local,
        _remote = remote;
  final EspJpnWordStatusLocalDataSource _local;
  final FirebaseEspJpnWordStatusRemoteStore _remote;
  @override
  SyncDataset get dataset => SyncDataset.espJpnWordStatus;
  @override
  Future<RemoteMutationAck> push(RemoteMutationRequest request) =>
      _remote.patchWordStatus(request);
  @override
  Future<List<WordStatusSyncRecord>> fetchWordStatusPage(
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
  Future<bool> acknowledgeWordStatus(
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
  Future<void> applyWordStatusRemote(WordStatusSyncRecord record,
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
