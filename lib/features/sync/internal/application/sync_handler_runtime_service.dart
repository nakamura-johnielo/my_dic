import 'package:my_dic/features/sync/internal/application/policy/exponential_backoff.dart';
import 'package:my_dic/features/sync/internal/application/policy/retry_policy.dart';
import 'package:my_dic/features/sync/internal/application/policy/sync_error_classifier.dart';
import 'package:my_dic/features/sync/port/dataset_sync_gateway.dart';
import 'package:my_dic/features/sync/port/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/model/sync_cursor.dart';
import 'package:my_dic/features/sync/port/session_fence.dart';
import 'package:my_dic/features/sync/port/sync_checkpoint_store.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';
import 'package:my_dic/features/sync/port/sync_queue.dart';
import 'sync_execution_guard.dart';

/// すべてのデータセットアダプターに共通する、永続的な Sync アルゴリズムです。
final class SyncHandlerRuntimeService implements SyncHandlerRuntime {
  SyncHandlerRuntimeService({
    required SyncQueue queue,
    required SyncCheckpointStore checkpoints,
    required SessionFence sessionFence,
    RetryPolicy? retryPolicy,
    SyncErrorClassifier? classifier,
    DateTime Function()? clock,
    this.pushBatchLimit = 50,
    this.leaseDuration = const Duration(minutes: 2),
  })  : _queue = queue,
        _checkpoints = checkpoints,
        _guard = SyncExecutionGuard(sessionFence),
        _retryPolicy = retryPolicy ?? ExponentialBackoff(),
        _classifier = classifier ?? const SyncErrorClassifier(),
        _clock = clock ?? DateTime.now;

  final SyncQueue _queue;
  final SyncCheckpointStore _checkpoints;
  final SyncExecutionGuard _guard;
  final RetryPolicy _retryPolicy;
  final SyncErrorClassifier _classifier;
  final DateTime Function() _clock;
  final int pushBatchLimit;
  final Duration leaseDuration;

  @override
  Future<DatasetSyncResult> run(
    SyncContext context,
    DatasetSyncGateway adapter,
  ) async {
    try {
      if (!_guard.canContinue(context)) return _cancelled(context);
      final now = _clock();
      var pushed = 0;
      String? errorCode;
      var retryable = true;
      final leases = await _queue.leasePending(
        accountId: context.accountId,
        dataset: adapter.dataset,
        limit: pushBatchLimit,
        now: now,
        leaseDuration: leaseDuration,
      );
      _guard.ensureCanContinue(context);
      for (final lease in leases) {
        if (!_guard.canContinue(context)) return _cancelled(context);
        try {
          final m = lease.mutation;
          final ack = await adapter.push(RemoteMutationRequest(
            accountId: context.accountId,
            entityId: m.entityId,
            mutationId: m.mutationId,
            fields: m.payload,
            fieldMask: m.fieldMask,
            clientUpdatedAt: m.clientUpdatedAt,
            baseRemoteRevision: m.baseRemoteRevision,
          ));
          _guard.ensureCanContinue(context);
          await adapter.transaction(() async {
            final updated = await adapter.acknowledge(
              mutation: m,
              leasedLocalRevision: lease.leasedLocalRevision,
              accountId: context.accountId,
              acknowledgement: ack,
            );
            if (!updated || !await _queue.ack(lease)) {
              throw StateError('Sync remote acknowledgement is stale');
            }
          });
          pushed++;
        } catch (error) {
          _guard.ensureCanContinue(context);
          final classified = _classifier.classify(error);
          if (classified.kind == SyncFailureKind.deadLetter) {
            await _queue.deadLetter(lease, errorCode: classified.code);
          } else {
            await _queue.retry(lease,
                errorCode: classified.code,
                nextAttemptAt: now
                    .add(_retryPolicy.delayForAttempt(lease.attemptCount + 1)));
          }
          errorCode = classified.code;
          retryable = classified.retryable;
        }
      }
      final cursor = await _checkpoints.read(
          accountId: context.accountId, dataset: adapter.dataset);
      _guard.ensureCanContinue(context);
      List<DatasetSyncRecord> records;
      try {
        records = await adapter.pull(context.accountId, cursor);
        _guard.ensureCanContinue(context);
      } catch (error) {
        _guard.ensureCanContinue(context);
        final classified = _classifier.classify(error);
        return DatasetSyncResult.failed(
          errorCode: errorCode ?? classified.code,
          retryable: errorCode != null ? retryable : classified.retryable,
          cursorUnchanged: true,
        );
      }
      var pulled = 0;
      var nextCursor = cursor;
      if (records.isNotEmpty) {
        final pending = await _queue.peekPending(
            accountId: context.accountId, dataset: adapter.dataset);
        _guard.ensureCanContinue(context);
        final skipped = <String, Set<String>>{};
        for (final m in pending) {
          skipped.putIfAbsent(m.entityId, () => {}).addAll(m.fieldMask);
        }
        await adapter.transaction(() async {
          for (final record in records) {
            _guard.ensureCanContinue(context);
            await record.applyRemote(
                accountId: context.accountId,
                skippedFields: skipped[record.entityId] ?? const {});
            pulled++;
            final candidate = SyncCursor(
                seconds: record.updatedAt.millisecondsSinceEpoch ~/ 1000,
                nanoseconds:
                    (record.updatedAt.microsecondsSinceEpoch % 1000000) * 1000,
                documentId: record.entityId);
            if (nextCursor == null || candidate.compareTo(nextCursor!) > 0)
              nextCursor = candidate;
          }
          if (nextCursor != null && (cursor == null || nextCursor != cursor)) {
            await _checkpoints.write(
                accountId: context.accountId,
                dataset: adapter.dataset,
                cursor: nextCursor!,
                lastSuccessfulAt: now);
          }
        });
      }
      _guard.ensureCanContinue(context);
      return errorCode == null
          ? DatasetSyncResult.success(
              pushedCount: pushed, pulledCount: pulled, cursor: nextCursor)
          : DatasetSyncResult.failed(
              errorCode: errorCode,
              retryable: retryable,
              cursorUnchanged: pulled == 0);
    } on SyncExecutionCancelled catch (_) {
      return _cancelled(context);
    }
  }

  DatasetSyncResult _cancelled(SyncContext context) =>
      DatasetSyncResult.cancelled(_guard.cancellationReason(context));
}
