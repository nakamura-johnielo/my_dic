import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/cancellation_token.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/port/sync_checkpoint_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/sync/word_status_dataset_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/sync/word_status_dataset_sync_handler.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/sync/word_status_sync_record.dart';

import '../../../../../helpers/sync/fake_sync_queue.dart';

class _CheckpointStore implements SyncCheckpointStore {
  SyncCursor? cursor;
  @override
  Future<SyncCursor?> read(
          {required String accountId, required SyncDataset dataset}) async =>
      cursor;
  @override
  Future<void> write(
      {required String accountId,
      required SyncDataset dataset,
      required SyncCursor cursor,
      required DateTime lastSuccessfulAt}) async {
    this.cursor = cursor;
  }
}

class _Adapter implements WordStatusDatasetAdapter {
  _Adapter(this.dataset, this.records);
  @override
  final SyncDataset dataset;
  final List<WordStatusSyncRecord> records;
  RemoteMutationRequest? request;
  Set<String>? skipped;
  @override
  Future<bool> acknowledge(
          {required int wordId,
          required String accountId,
          required int localRevision,
          required String remoteRevision,
          required String? lastMutationId}) async =>
      true;
  @override
  Future<void> applyRemote(WordStatusSyncRecord record,
      {required String accountId, required Set<String> skippedFields}) async {
    skipped = skippedFields;
  }

  @override
  Future<List<WordStatusSyncRecord>> fetchPage(
          String accountId, SyncCursor? cursor) async =>
      records;
  @override
  Future<RemoteMutationAck> patch(RemoteMutationRequest request) async {
    this.request = request;
    return const RemoteMutationAck(
        status: RemoteMutationAckStatus.applied,
        remoteRevision: 7,
        lastMutationId: 'ack',
        serverUpdatedAt: null);
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) => action();
}

void main() {
  for (final dataset in [
    SyncDataset.espJpnWordStatus,
    SyncDataset.jpnEspWordStatus
  ]) {
    test('$dataset uses its own queue dataset and preserves field masks',
        () async {
      final queue = FakeSyncQueue();
      queue.enqueue(SyncMutation(
          mutationId: 'm',
          accountId: 'a',
          dataset: dataset,
          entityId: '42',
          operation: SyncMutationOperation.patch,
          payload: const {'isLearned': true},
          fieldMask: const ['isLearned'],
          localRevision: 1,
          clientUpdatedAt: DateTime.utc(2026)));
      final adapter = _Adapter(dataset, [
        WordStatusSyncRecord(
            wordId: 42,
            isLearned: false,
            isBookmarked: true,
            hasNote: false,
            updatedAt: DateTime.utc(2026, 1, 2),
            remoteRevision: 8)
      ]);
      final checkpoints = _CheckpointStore();
      final result = await WordStatusDatasetSyncHandler(
              adapter: adapter,
              queue: queue,
              checkpointStore: checkpoints,
              clock: () => DateTime.utc(2026))
          .run(SyncContext(
              accountId: 'a',
              sessionEpoch: 1,
              reason: 'test',
              cancellation: CancellationToken()));
      expect(adapter.request!.fieldMask, const ['isLearned']);
      expect(adapter.skipped, isEmpty);
      expect(queue.pending, isEmpty);
      expect(result.toString(), contains('DatasetSyncSuccess'));
      expect(checkpoints.cursor!.documentId, '42');
    });
  }
}
