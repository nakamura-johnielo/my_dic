import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/sync/internal/application/sync_handler_runtime_adapter.dart';
import 'package:my_dic/features/sync/port/cancellation_token.dart';
import 'package:my_dic/features/sync/port/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/model/sync_cursor.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/session_fence.dart';
import 'package:my_dic/features/sync/port/sync_checkpoint_store.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/sync/word_status_dataset_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/sync/word_status_dataset_sync_handler.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/sync/word_status_sync_record.dart';

import '../../../helpers/sync/fake_sync_queue.dart';

const _accountId = 'account-a';

SyncMutation _mutation(SyncDataset dataset, [String suffix = '']) =>
    SyncMutation(
      mutationId: 'mutation-${dataset.stableId}$suffix',
      accountId: _accountId,
      dataset: dataset,
      entityId: '1',
      operation: SyncMutationOperation.patch,
      payload: const {'isBookmarked': true},
      fieldMask: const ['isBookmarked'],
      localRevision: 1,
      clientUpdatedAt: DateTime.utc(2026),
    );

class _Adapter extends WordStatusDatasetAdapter {
  _Adapter(this.dataset);

  @override
  final SyncDataset dataset;
  final records = <WordStatusSyncRecord>[];
  final applied = <WordStatusSyncRecord>[];
  final acknowledged = <int>[];
  Object? patchError;
  void Function()? afterPatch;

  @override
  Future<RemoteMutationAck> push(RemoteMutationRequest request) async {
    if (patchError != null) throw patchError!;
    afterPatch?.call();
    return const RemoteMutationAck(
      status: RemoteMutationAckStatus.applied,
      remoteRevision: 1,
      lastMutationId: 'remote-mutation',
      serverUpdatedAt: null,
    );
  }

  @override
  Future<List<WordStatusSyncRecord>> fetchWordStatusPage(
          String accountId, SyncCursor? cursor) async =>
      records;

  @override
  Future<T> transaction<T>(Future<T> Function() action) => action();

  @override
  Future<bool> acknowledgeWordStatus({
    required int wordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  }) async {
    acknowledged.add(wordId);
    return true;
  }

  @override
  Future<void> applyWordStatusRemote(
    WordStatusSyncRecord record, {
    required String accountId,
    required Set<String> skippedFields,
  }) async {
    applied.add(record);
  }
}

class _CheckpointStore implements SyncCheckpointStore {
  SyncCursor? cursor;

  @override
  Future<SyncCursor?> read({
    required String accountId,
    required SyncDataset dataset,
  }) async =>
      cursor;

  @override
  Future<void> write({
    required String accountId,
    required SyncDataset dataset,
    required SyncCursor cursor,
    required DateTime lastSuccessfulAt,
  }) async {
    this.cursor = cursor;
  }
}

final class _SessionFence implements SessionFence {
  @override
  bool isCurrent({required String accountId, required int sessionEpoch}) =>
      true;
}

void main() {
  for (final dataset in [
    SyncDataset.espJpnWordStatus,
    SyncDataset.jpnEspWordStatus,
  ]) {
    group('${dataset.stableId} common handler', () {
      late _Adapter adapter;
      late FakeSyncQueue queue;
      late WordStatusDatasetSyncHandler handler;

      setUp(() {
        adapter = _Adapter(dataset);
        queue = FakeSyncQueue();
        handler = WordStatusDatasetSyncHandler(
          adapter: adapter,
          runtime: SyncHandlerRuntimeAdapter(
            queue: queue,
            checkpoints: _CheckpointStore(),
            sessionFence: _SessionFence(),
            clock: () => DateTime.utc(2026, 8, 6),
          ),
        );
      });

      SyncContext context(CancellationToken cancellation) => SyncContext(
            accountId: _accountId,
            sessionEpoch: 1,
            reason: 'test',
            cancellation: cancellation,
          );

      test('pushes a leased patch and acknowledges it', () async {
        queue.enqueue(_mutation(dataset));

        final result = await handler.run(context(CancellationToken()));

        expect(result, isA<DatasetSyncSuccess>());
        expect((result as DatasetSyncSuccess).pushedCount, 1);
        expect(adapter.acknowledged, [1]);
        expect(queue.pending, isEmpty);
      });

      test('does not acknowledge after session invalidation', () async {
        final cancellation = CancellationToken();
        adapter.afterPatch = () => cancellation.cancel('account changed');
        queue.enqueue(_mutation(dataset));

        final result = await handler.run(context(cancellation));

        expect(result, isA<DatasetSyncCancelled>());
        expect(adapter.acknowledged, isEmpty);
        expect(queue.leased, hasLength(1));
      });

      test('retries retryable failures and dead-letters invalid failures',
          () async {
        queue.enqueue(_mutation(dataset));
        adapter.patchError = Exception('unavailable');
        final retryResult = await handler.run(context(CancellationToken()));
        expect(retryResult, isA<DatasetSyncFailed>());
        expect(queue.pending, hasLength(1));

        adapter.patchError = Exception('invalid-argument');
        queue.enqueue(_mutation(dataset, '-invalid'));
        final deadLetterResult =
            await handler.run(context(CancellationToken()));
        expect(deadLetterResult, isA<DatasetSyncFailed>());
        expect(queue.deadLetters, hasLength(1));
      });

      test('applies remote records and advances the checkpoint', () async {
        final updatedAt = DateTime.utc(2026, 8, 5, 12);
        adapter.records.add(WordStatusSyncRecord(
          wordId: 2,
          isLearned: true,
          isBookmarked: false,
          hasNote: false,
          updatedAt: updatedAt,
          remoteRevision: 1,
          lastMutationId: null,
        ));

        final result = await handler.run(context(CancellationToken()));

        expect(result, isA<DatasetSyncSuccess>());
        expect((result as DatasetSyncSuccess).pulledCount, 1);
        expect(adapter.applied.single.wordId, 2);
        expect(
            result.cursor,
            SyncCursor(
              seconds: updatedAt.millisecondsSinceEpoch ~/ 1000,
              nanoseconds: (updatedAt.microsecondsSinceEpoch % 1000000) * 1000,
              documentId: '2',
            ));
      });
    });
  }
}
