import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/model/mutation_lease.dart';

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
}
