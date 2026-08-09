import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';
import 'package:my_dic/features/sync/application/policy/exponential_backoff.dart';
import 'package:my_dic/features/sync/application/policy/retry_policy.dart';
import 'package:my_dic/features/sync/application/policy/sync_error_classifier.dart';
import 'package:my_dic/features/sync/application/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/application/port/sync_checkpoint_store.dart';
import 'package:my_dic/features/sync/application/port/sync_queue.dart';
import 'package:my_dic/features/sync/application/sync_execution_guard.dart';
import 'word_status_dataset_adapter.dart';

/// The sole WordStatus synchronization algorithm. Direction adapters only map
/// their Drift/Firebase representations to the neutral contract.
final class WordStatusDatasetSyncHandler implements DatasetSyncHandler {
  WordStatusDatasetSyncHandler({
    required WordStatusDatasetAdapter adapter,
    required SyncQueue queue,
    required SyncCheckpointStore checkpointStore,
    RetryPolicy? retryPolicy,
    SyncErrorClassifier? classifier,
    SyncExecutionGuard? executionGuard,
    DateTime Function()? clock,
    this.pushBatchLimit = 50,
    this.leaseDuration = const Duration(minutes: 2),
  })  : _adapter = adapter,
        _queue = queue,
        _checkpointStore = checkpointStore,
        _retryPolicy = retryPolicy ?? ExponentialBackoff(),
        _classifier = classifier ?? const SyncErrorClassifier(),
        _executionGuard = executionGuard ?? const SyncExecutionGuard(),
        _clock = clock ?? DateTime.now;

  final WordStatusDatasetAdapter _adapter;
  final SyncQueue _queue;
  final SyncCheckpointStore _checkpointStore;
  final RetryPolicy _retryPolicy;
  final SyncErrorClassifier _classifier;
  final SyncExecutionGuard _executionGuard;
  final DateTime Function() _clock;
  final int pushBatchLimit;
  final Duration leaseDuration;

  @override
  SyncDataset get dataset => _adapter.dataset;

  @override
  Future<DatasetSyncResult> run(SyncContext context) async {
    try {
      if (!_executionGuard.canContinue(context)) {
        return _cancelled(context);
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
          leaseDuration: leaseDuration);
      _executionGuard.ensureCanContinue(context);
      for (final lease in leases) {
        if (!_executionGuard.canContinue(context)) {
          return _cancelled(context);
        }
        try {
          final ack = await _adapter.patch(RemoteMutationRequest(
              accountId: context.accountId,
              entityId: lease.mutation.entityId,
              mutationId: lease.mutation.mutationId,
              fields: lease.mutation.payload,
              fieldMask: lease.mutation.fieldMask,
              clientUpdatedAt: lease.mutation.clientUpdatedAt,
              baseRemoteRevision: lease.mutation.baseRemoteRevision));
          if (!_executionGuard.canContinue(context)) return _cancelled(context);
          await _adapter.transaction(() async {
            final updated = await _adapter.acknowledge(
                wordId: int.parse(lease.mutation.entityId),
                accountId: context.accountId,
                localRevision: lease.leasedLocalRevision,
                remoteRevision: ack.remoteRevision.toString(),
                lastMutationId: ack.lastMutationId);
            if (!updated || !await _queue.ack(lease)) {
              throw StateError('WordStatus remote acknowledgement is stale');
            }
          });
          pushedCount++;
        } catch (error) {
          _executionGuard.ensureCanContinue(context);
          final classification = _classifier.classify(error);
          if (classification.kind == SyncFailureKind.deadLetter) {
            await _queue.deadLetter(lease, errorCode: classification.code);
          } else {
            await _queue.retry(lease,
                errorCode: classification.code,
                nextAttemptAt: now
                    .add(_retryPolicy.delayForAttempt(lease.attemptCount + 1)));
          }
          pushErrorCode = classification.code;
          pushRetryable = classification.retryable;
        }
      }
      if (!_executionGuard.canContinue(context)) return _cancelled(context);
      final cursor = await _checkpointStore.read(
          accountId: context.accountId, dataset: dataset);
      _executionGuard.ensureCanContinue(context);
      final records = await _adapter.fetchPage(context.accountId, cursor);
      _executionGuard.ensureCanContinue(context);
      var pulledCount = 0;
      var newCursor = cursor;
      if (records.isNotEmpty) {
        final pending = await _queue.peekPending(
            accountId: context.accountId, dataset: dataset);
        _executionGuard.ensureCanContinue(context);
        final skippedByEntity = <String, Set<String>>{};
        for (final mutation in pending) {
          skippedByEntity
              .putIfAbsent(mutation.entityId, () => {})
              .addAll(mutation.fieldMask);
        }
        await _adapter.transaction(() async {
          for (final record in records) {
            _executionGuard.ensureCanContinue(context);
            await _adapter.applyRemote(record,
                accountId: context.accountId,
                skippedFields:
                    skippedByEntity[record.wordId.toString()] ?? const {});
            _executionGuard.ensureCanContinue(context);
            pulledCount++;
            final candidate = SyncCursor(
                seconds: record.updatedAt.millisecondsSinceEpoch ~/ 1000,
                nanoseconds:
                    (record.updatedAt.microsecondsSinceEpoch % 1000000) * 1000,
                documentId: record.wordId.toString());
            if (newCursor == null || candidate.compareTo(newCursor!) > 0) {
              newCursor = candidate;
            }
          }
          if (newCursor != null && (cursor == null || newCursor != cursor)) {
            _executionGuard.ensureCanContinue(context);
            await _checkpointStore.write(
                accountId: context.accountId,
                dataset: dataset,
                cursor: newCursor!,
                lastSuccessfulAt: now);
          }
          _executionGuard.ensureCanContinue(context);
        });
      }
      _executionGuard.ensureCanContinue(context);
      if (pushErrorCode != null) {
        return DatasetSyncResult.failed(
            errorCode: pushErrorCode,
            retryable: pushRetryable,
            cursorUnchanged: pulledCount == 0);
      }
      return DatasetSyncResult.success(
          pushedCount: pushedCount,
          pulledCount: pulledCount,
          cursor: newCursor);
    } on SyncExecutionCancelled catch (error) {
      return DatasetSyncResult.cancelled(error.reason);
    }
  }

  DatasetSyncResult _cancelled(SyncContext context) =>
      DatasetSyncResult.cancelled(_executionGuard.cancellationReason(context));
}
