import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/model/mutation_lease.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/port/sync_queue.dart';

class FakeSyncQueue implements SyncQueue {
  final List<SyncMutation> pending = [];
  final Map<String, MutationLease> leased = {};
  final Set<String> deadLetters = {};
  int _token = 0;

  void enqueue(SyncMutation mutation) => pending.add(mutation);

  @override
  Future<List<MutationLease>> leasePending(
      {required String accountId,
      required SyncDataset dataset,
      required int limit,
      required DateTime now,
      required Duration leaseDuration}) async {
    final matches = pending
        .where((item) => item.accountId == accountId && item.dataset == dataset)
        .take(limit)
        .toList();
    final result = <MutationLease>[];
    for (final mutation in matches) {
      pending.remove(mutation);
      final lease = MutationLease(
          mutation: mutation,
          leaseToken: 'fake-${_token++}',
          leasedLocalRevision: mutation.localRevision,
          leaseUntil: now.add(leaseDuration));
      leased[mutation.mutationId] = lease;
      result.add(lease);
    }
    return result;
  }

  bool _owns(MutationLease lease) =>
      leased[lease.mutation.mutationId]?.leaseToken == lease.leaseToken &&
      lease.mutation.localRevision == lease.leasedLocalRevision;

  @override
  Future<bool> ack(MutationLease lease) async =>
      _owns(lease) && leased.remove(lease.mutation.mutationId) != null;

  @override
  Future<void> retry(MutationLease lease,
      {required String errorCode, required DateTime nextAttemptAt}) async {
    if (_owns(lease)) {
      leased.remove(lease.mutation.mutationId);
      pending.add(lease.mutation);
    }
  }

  @override
  Future<void> deadLetter(MutationLease lease,
      {required String errorCode}) async {
    if (_owns(lease)) {
      leased.remove(lease.mutation.mutationId);
      deadLetters.add(lease.mutation.mutationId);
    }
  }

  @override
  Future<int> releaseExpiredLeases(DateTime now) async {
    final expired =
        leased.values.where((lease) => lease.leaseUntil.isBefore(now)).toList();
    for (final lease in expired) {
      leased.remove(lease.mutation.mutationId);
      pending.add(lease.mutation);
    }
    return expired.length;
  }
}
