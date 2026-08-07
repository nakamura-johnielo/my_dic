import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_local_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/myword/i_my_word_remote_data_source.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';
import 'package:my_dic/features/sync/application/policy/exponential_backoff.dart';
import 'package:my_dic/features/sync/application/policy/retry_policy.dart';
import 'package:my_dic/features/sync/application/policy/sync_error_classifier.dart';
import 'package:my_dic/features/sync/application/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/application/port/sync_checkpoint_store.dart';
import 'package:my_dic/features/sync/application/port/sync_queue.dart';

/// Pushes queued MyWord mutations (create/update/delete alike, since all three
/// carry a field mask + payload) to Firestore as merge-write patches and pulls
/// remote changes back into Drift, skipping any field that still has an
/// unacked local mutation in flight. A remote `deletedAt` tombstones the row
/// locally instead of resurrecting it.
class MyWordSyncHandler implements DatasetSyncHandler {
  MyWordSyncHandler({
    required SyncQueue queue,
    required SyncCheckpointStore checkpointStore,
    required IMyWordLocalDataSource local,
    required IMyWordRemoteDataSource remote,
    RetryPolicy? retryPolicy,
    SyncErrorClassifier? classifier,
    DateTime Function()? clock,
    this.pushBatchLimit = 50,
    this.leaseDuration = const Duration(minutes: 2),
  })  : _queue = queue,
        _checkpointStore = checkpointStore,
        _local = local,
        _remote = remote,
        _retryPolicy = retryPolicy ?? ExponentialBackoff(),
        _classifier = classifier ?? const SyncErrorClassifier(),
        _clock = clock ?? DateTime.now;

  final SyncQueue _queue;
  final SyncCheckpointStore _checkpointStore;
  final IMyWordLocalDataSource _local;
  final IMyWordRemoteDataSource _remote;
  final RetryPolicy _retryPolicy;
  final SyncErrorClassifier _classifier;
  final DateTime Function() _clock;
  final int pushBatchLimit;
  final Duration leaseDuration;

  @override
  SyncDataset get dataset => SyncDataset.myWords;

  @override
  Future<DatasetSyncResult> run(SyncContext context) async {
    if (context.cancellation.isCancelled) {
      return const DatasetSyncResult.cancelled('cancelled before start');
    }

    final now = _clock();
    var pushedCount = 0;
    String? pushErrorCode;
    var pushRetryable = true;

    final leases = await _queue.leasePending(
      accountId: context.accountId,
      dataset: dataset,
      limit: pushBatchLimit,
      now: now,
      leaseDuration: leaseDuration,
    );

    for (final lease in leases) {
      if (context.cancellation.isCancelled) {
        return const DatasetSyncResult.cancelled('cancelled during push');
      }
      try {
        final entityId = lease.mutation.entityId;
        final existing =
            await _remote.getMyWordById(context.accountId, entityId);
        await _remote.patchMyWord(
          context.accountId,
          entityId,
          lease.mutation.payload,
          lease.mutation.fieldMask,
          isNew: existing == null,
        );
        if (await _queue.ack(lease)) pushedCount++;
      } catch (error) {
        final classification = _classifier.classify(error);
        if (classification.kind == SyncFailureKind.deadLetter) {
          await _queue.deadLetter(lease, errorCode: classification.code);
        } else {
          await _queue.retry(lease,
              errorCode: classification.code,
              nextAttemptAt: now.add(_retryPolicy.delayForAttempt(1)));
        }
        pushErrorCode = classification.code;
        pushRetryable = classification.retryable;
      }
    }

    if (context.cancellation.isCancelled) {
      return const DatasetSyncResult.cancelled('cancelled after push');
    }

    final cursor = await _checkpointStore.read(
        accountId: context.accountId, dataset: dataset);
    final since = cursor == null ? MyDateTime.sentinel : _toDateTime(cursor);
    final remoteItems = await _remote.getMyWordsAfter(context.accountId, since);

    var pulledCount = 0;
    var newCursor = cursor;

    if (remoteItems.isNotEmpty) {
      final pending = await _queue.peekPending(
          accountId: context.accountId, dataset: dataset);
      final pendingFieldsByEntity = <String, Set<String>>{};
      for (final mutation in pending) {
        pendingFieldsByEntity
            .putIfAbsent(mutation.entityId, () => {})
            .addAll(mutation.fieldMask);
      }

      await _local.runInTransaction(() async {
        for (final dto in remoteItems) {
          final entityId = dto.myWordId;
          final skip = pendingFieldsByEntity[entityId] ?? const {};
          final tombstoned = dto.deletedAt != null;
          await _local.applyRemoteFields(
            entityId,
            word: skip.contains('word') ? null : dto.word,
            contents: skip.contains('contents') ? null : dto.contents,
            deletedAt: tombstoned ? dto.deletedAt!.toIso8601String() : null,
            editAt: dto.updatedAt.toIso8601String(),
            accountId: context.accountId,
          );
          pulledCount++;
          final candidate = SyncCursor(
            seconds: dto.updatedAt.millisecondsSinceEpoch ~/ 1000,
            nanoseconds:
                (dto.updatedAt.microsecondsSinceEpoch % 1000000) * 1000,
            documentId: entityId,
          );
          if (newCursor == null || candidate.compareTo(newCursor!) > 0) {
            newCursor = candidate;
          }
        }
        if (newCursor != null && (cursor == null || newCursor != cursor)) {
          await _checkpointStore.write(
            accountId: context.accountId,
            dataset: dataset,
            cursor: newCursor!,
            lastSuccessfulAt: now,
          );
        }
      });
    }

    if (pushErrorCode != null) {
      return DatasetSyncResult.failed(
        errorCode: pushErrorCode,
        retryable: pushRetryable,
        cursorUnchanged: pulledCount == 0,
      );
    }

    return DatasetSyncResult.success(
      pushedCount: pushedCount,
      pulledCount: pulledCount,
      cursor: newCursor,
    );
  }

  DateTime _toDateTime(SyncCursor cursor) => DateTime.fromMicrosecondsSinceEpoch(
      cursor.seconds * 1000000 + cursor.nanoseconds ~/ 1000,
      isUtc: true);
}
