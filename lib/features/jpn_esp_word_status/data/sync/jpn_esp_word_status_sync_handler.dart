import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/i_local_jpn_esp_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/i_remote_jpn_esp_word_status_data_source.dart';
import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';
import 'package:my_dic/features/sync/application/sync_execution_guard.dart';
import 'package:my_dic/features/sync/application/policy/exponential_backoff.dart';
import 'package:my_dic/features/sync/application/policy/retry_policy.dart';
import 'package:my_dic/features/sync/application/policy/sync_error_classifier.dart';
import 'package:my_dic/features/sync/application/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/application/port/sync_checkpoint_store.dart';
import 'package:my_dic/features/sync/application/port/sync_queue.dart';

/// Pushes queued Jpn-Esp word status mutations to Firestore as field-mask
/// patches and pulls remote changes back into Drift, skipping any field that
/// still has an unacked local mutation in flight.
class JpnEspWordStatusSyncHandler implements DatasetSyncHandler {
  JpnEspWordStatusSyncHandler({
    required SyncQueue queue,
    required SyncCheckpointStore checkpointStore,
    required ILocalJpnEspWordStatusDataSource local,
    required IRemoteJpnEspWordStatusDataSource remote,
    RetryPolicy? retryPolicy,
    SyncErrorClassifier? classifier,
    SyncExecutionGuard? executionGuard,
    DateTime Function()? clock,
    this.pushBatchLimit = 50,
    this.leaseDuration = const Duration(minutes: 2),
  })  : _queue = queue,
        _checkpointStore = checkpointStore,
        _local = local,
        _remote = remote,
        _retryPolicy = retryPolicy ?? ExponentialBackoff(),
        _classifier = classifier ?? const SyncErrorClassifier(),
        _executionGuard = executionGuard ?? const SyncExecutionGuard(),
        _clock = clock ?? DateTime.now;

  final SyncQueue _queue;
  final SyncCheckpointStore _checkpointStore;
  final ILocalJpnEspWordStatusDataSource _local;
  final IRemoteJpnEspWordStatusDataSource _remote;
  final RetryPolicy _retryPolicy;
  final SyncErrorClassifier _classifier;
  final SyncExecutionGuard _executionGuard;
  final DateTime Function() _clock;
  final int pushBatchLimit;
  final Duration leaseDuration;

  @override
  SyncDataset get dataset => SyncDataset.jpnEspWordStatus;

  @override
  Future<DatasetSyncResult> run(SyncContext context) async {
    try {
      return await _run(context);
    } on SyncExecutionCancelled catch (error) {
      return DatasetSyncResult.cancelled(error.reason);
    }
  }

  Future<DatasetSyncResult> _run(SyncContext context) async {
    if (!_executionGuard.canContinue(context)) {
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
    _executionGuard.ensureCanContinue(context);

    for (final lease in leases) {
      if (!_executionGuard.canContinue(context)) {
        return const DatasetSyncResult.cancelled('cancelled during push');
      }
      try {
        final wordId = int.parse(lease.mutation.entityId);
        final existing =
            await _remote.getWordStatusById(context.accountId, wordId);
        _executionGuard.ensureCanContinue(context);
        await _remote.patchWordStatus(
          context.accountId,
          wordId,
          lease.mutation.payload,
          lease.mutation.fieldMask,
          isNew: existing == null,
        );
        if (!_executionGuard.canContinue(context)) {
          return DatasetSyncResult.cancelled(
              _executionGuard.cancellationReason(context));
        }
        if (await _queue.ack(lease)) pushedCount++;
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

    if (!_executionGuard.canContinue(context)) {
      return const DatasetSyncResult.cancelled('cancelled after push');
    }

    final cursor = await _checkpointStore.read(
        accountId: context.accountId, dataset: dataset);
    _executionGuard.ensureCanContinue(context);
    final since = cursor == null ? MyDateTime.sentinel : _toDateTime(cursor);
    final remoteItems =
        await _remote.getWordStatusAfter(context.accountId, since);
    _executionGuard.ensureCanContinue(context);

    var pulledCount = 0;
    var newCursor = cursor;

    if (remoteItems.isNotEmpty) {
      if (!_executionGuard.canContinue(context)) {
        return DatasetSyncResult.cancelled(
            _executionGuard.cancellationReason(context));
      }
      final pending = await _queue.peekPending(
          accountId: context.accountId, dataset: dataset);
      _executionGuard.ensureCanContinue(context);
      final pendingFieldsByEntity = <String, Set<String>>{};
      for (final mutation in pending) {
        pendingFieldsByEntity
            .putIfAbsent(mutation.entityId, () => {})
            .addAll(mutation.fieldMask);
      }

      await _local.runInTransaction(() async {
        for (final dto in remoteItems) {
          _executionGuard.ensureCanContinue(context);
          final entity = dto.toDomain();
          final entityId = entity.wordId.toString();
          final skip = pendingFieldsByEntity[entityId] ?? const {};
          await _local.applyRemoteFields(
            entity.wordId,
            isLearned: skip.contains('isLearned') ? null : entity.isLearned,
            isBookmarked:
                skip.contains('isBookmarked') ? null : entity.isBookmarked,
            hasNote: skip.contains('hasNote') ? null : entity.hasNote,
            editAt: entity.editAt.toIso8601String(),
            accountId: context.accountId,
          );
          _executionGuard.ensureCanContinue(context);
          pulledCount++;
          final candidate = SyncCursor(
            seconds: entity.editAt.millisecondsSinceEpoch ~/ 1000,
            nanoseconds:
                (entity.editAt.microsecondsSinceEpoch % 1000000) * 1000,
            documentId: entityId,
          );
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
            lastSuccessfulAt: now,
          );
        }
        _executionGuard.ensureCanContinue(context);
      });
    }

    _executionGuard.ensureCanContinue(context);

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

  DateTime _toDateTime(SyncCursor cursor) =>
      DateTime.fromMicrosecondsSinceEpoch(
          cursor.seconds * 1000000 + cursor.nanoseconds ~/ 1000,
          isUtc: true);
}
