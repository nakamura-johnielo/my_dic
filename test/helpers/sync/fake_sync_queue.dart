import 'package:my_dic/features/sync/port/model/mutation_lease.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/sync/port/sync_queue.dart';

class FakeSyncQueue implements SyncQueue {
  final List<SyncMutation> pending = [];
  final Map<String, MutationLease> leased = {};
  final Set<String> deadLetters = {};
  final Map<String, int> _attempts = {};
  final Map<String, DateTime> nextAttemptAt = {};
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
        .where((item) =>
            item.accountId == accountId &&
            item.dataset == dataset &&
            !(nextAttemptAt[item.mutationId]?.isAfter(now.toUtc()) ?? false))
        .take(limit)
        .toList();
    final result = <MutationLease>[];
    for (final mutation in matches) {
      pending.remove(mutation);
      final lease = MutationLease(
          mutation: mutation,
          leaseToken: 'fake-${_token++}',
          leasedLocalRevision: mutation.localRevision,
          leaseUntil: now.add(leaseDuration),
          attemptCount: _attempts[mutation.mutationId] ?? 0);
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
      _attempts.update(lease.mutation.mutationId, (attempt) => attempt + 1,
          ifAbsent: () => 1);
      this.nextAttemptAt[lease.mutation.mutationId] = nextAttemptAt.toUtc();
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

  @override
  Future<DateTime?> earliestPendingAttemptAt(
      {required String accountId}) async {
    DateTime? earliest;
    for (final mutation
        in pending.where((item) => item.accountId == accountId)) {
      final dueAt =
          nextAttemptAt[mutation.mutationId] ?? mutation.clientUpdatedAt;
      if (earliest == null || dueAt.toUtc().isBefore(earliest)) {
        earliest = dueAt.toUtc();
      }
    }
    return earliest;
  }

  @override
  Future<List<SyncMutation>> peekPending(
      {required String accountId, required SyncDataset dataset}) async {
    return [
      ...pending,
      ...leased.values.map((lease) => lease.mutation),
    ]
        .where((mutation) =>
            mutation.accountId == accountId && mutation.dataset == dataset)
        .toList();
  }
}
