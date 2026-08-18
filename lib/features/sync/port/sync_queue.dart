import 'model/mutation_lease.dart';
import 'model/sync_mutation.dart';
import 'sync_dataset.dart';

abstract interface class SyncQueue {
  Future<List<MutationLease>> leasePending(
      {required String accountId,
      required SyncDataset dataset,
      required int limit,
      required DateTime now,
      required Duration leaseDuration});
  Future<bool> ack(MutationLease lease);
  Future<void> retry(MutationLease lease,
      {required String errorCode, required DateTime nextAttemptAt});
  Future<void> deadLetter(MutationLease lease, {required String errorCode});
  Future<int> releaseExpiredLeases(DateTime now);

  /// The earliest retry due time for pending mutations belonging to [accountId].
  /// Leased and dead-letter mutations are deliberately excluded.
  Future<DateTime?> earliestPendingAttemptAt({required String accountId});

  /// Non-mutating read of mutations that have not been acked yet (pending or
  /// currently leased). Handlers use this to avoid overwriting a field with
  /// a stale remote value while a local change for that field is still
  /// in-flight to the server.
  Future<List<SyncMutation>> peekPending(
      {required String accountId, required SyncDataset dataset});
}
