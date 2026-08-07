import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';
import 'package:my_dic/features/sync/application/policy/exponential_backoff.dart';
import 'package:my_dic/features/sync/application/policy/retry_policy.dart';
import 'package:my_dic/features/sync/application/policy/sync_error_classifier.dart';
import 'package:my_dic/features/sync/application/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/application/port/sync_checkpoint_store.dart';
import 'package:my_dic/features/sync/application/port/sync_queue.dart';
import 'package:my_dic/features/user/data/data_source/local/i_user_profile_local_data_source.dart';
import 'package:my_dic/features/user/data/data_source/remote/i_user_remote_data_source.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';

/// Pushes queued editable-profile mutations (currently just `username`) to
/// Firestore as field-mask patches and pulls the remote profile document
/// back into Drift, skipping any field that still has an unacked local
/// mutation in flight. There is exactly one entity (the account's own
/// profile document) per account, so pull compares the document's single
/// `updatedAt` against the stored checkpoint instead of a range query.
class UserProfileSyncHandler implements DatasetSyncHandler {
  UserProfileSyncHandler({
    required SyncQueue queue,
    required SyncCheckpointStore checkpointStore,
    required IUserProfileLocalDataSource local,
    required IUserRemoteDataSource remote,
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
  final IUserProfileLocalDataSource _local;
  final IUserRemoteDataSource _remote;
  final RetryPolicy _retryPolicy;
  final SyncErrorClassifier _classifier;
  final DateTime Function() _clock;
  final int pushBatchLimit;
  final Duration leaseDuration;

  @override
  SyncDataset get dataset => SyncDataset.userProfile;

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
        final existing = await _remote.getUserById(context.accountId);
        await _remote.patchUser(
          context.accountId,
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

    UserDTO? remoteUser;
    String? pullErrorCode;
    var pullRetryable = true;
    try {
      remoteUser = await _remote.getUserById(context.accountId);
    } catch (error) {
      final classification = _classifier.classify(error);
      pullErrorCode = classification.code;
      pullRetryable = classification.retryable;
    }

    var pulledCount = 0;
    var newCursor = cursor;

    if (remoteUser != null && remoteUser.updatedAt != null) {
      final candidate = SyncCursor(
        seconds: remoteUser.updatedAt!.millisecondsSinceEpoch ~/ 1000,
        nanoseconds:
            (remoteUser.updatedAt!.microsecondsSinceEpoch % 1000000) * 1000,
        documentId: context.accountId,
      );
      if (cursor == null || candidate.compareTo(cursor) > 0) {
        final pending = await _queue.peekPending(
            accountId: context.accountId, dataset: dataset);
        final pendingFields = <String>{
          for (final mutation in pending) ...mutation.fieldMask,
        };

        await _local.runInTransaction(() async {
          await _local.applyRemoteFields(
            context.accountId,
            username: pendingFields.contains('username')
                ? null
                : remoteUser!.userName,
          );
          await _checkpointStore.write(
            accountId: context.accountId,
            dataset: dataset,
            cursor: candidate,
            lastSuccessfulAt: now,
          );
        });
        pulledCount = 1;
        newCursor = candidate;
      }
    }

    final errorCode = pushErrorCode ?? pullErrorCode;
    if (errorCode != null) {
      return DatasetSyncResult.failed(
        errorCode: errorCode,
        retryable: pushErrorCode != null ? pushRetryable : pullRetryable,
        cursorUnchanged: pulledCount == 0,
      );
    }

    return DatasetSyncResult.success(
      pushedCount: pushedCount,
      pulledCount: pulledCount,
      cursor: newCursor,
    );
  }
}

