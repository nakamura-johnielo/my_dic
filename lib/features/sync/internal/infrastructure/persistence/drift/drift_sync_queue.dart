import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/port/model/mutation_lease.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/sync/port/sync_queue.dart';

class DriftSyncQueue implements SyncQueue {
  DriftSyncQueue(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();
  final DatabaseProvider _db;
  final Uuid _uuid;
  @override
  Future<List<MutationLease>> leasePending(
      {required String accountId,
      required SyncDataset dataset,
      required int limit,
      required DateTime now,
      required Duration leaseDuration}) async {
    if (limit <= 0) return const [];
    return _db.transaction(() async {
      await releaseExpiredLeases(now);
      final candidates = await (_db.select(_db.syncOutbox)
            ..where((r) =>
                r.accountId.equals(accountId) &
                r.dataset.equals(dataset.stableId) &
                r.state.equals('pending') &
                r.nextAttemptAt.isSmallerOrEqualValue(now.toUtc()))
            ..orderBy([(r) => OrderingTerm.asc(r.createdAt)])
            ..limit(limit))
          .get();
      final until = now.toUtc().add(leaseDuration);
      final result = <MutationLease>[];
      for (final row in candidates) {
        final token = _uuid.v4();
        final updated = await (_db.update(_db.syncOutbox)
              ..where((r) =>
                  r.mutationId.equals(row.mutationId) &
                  r.state.equals('pending')))
            .write(SyncOutboxCompanion(
                state: const Value('leased'),
                leaseToken: Value(token),
                leaseUntil: Value(until)));
        if (updated == 1) {
          result.add(MutationLease(
              mutation: _mutation(row),
              leaseToken: token,
              leasedLocalRevision: row.localRevision,
              leaseUntil: until,
              attemptCount: row.attemptCount));
        }
      }
      return result;
    });
  }

  @override
  Future<bool> ack(MutationLease lease) async {
    final changed = await (_db.delete(_db.syncOutbox)
          ..where((r) =>
              r.mutationId.equals(lease.mutation.mutationId) &
              r.state.equals('leased') &
              r.leaseToken.equals(lease.leaseToken) &
              r.localRevision.equals(lease.leasedLocalRevision)))
        .go();
    return changed == 1;
  }

  @override
  Future<void> retry(MutationLease lease,
      {required String errorCode, required DateTime nextAttemptAt}) async {
    await _transition(
        lease,
        SyncOutboxCompanion(
            state: const Value('pending'),
            attemptCount: const Value.absent(),
            nextAttemptAt: Value(nextAttemptAt.toUtc()),
            leaseToken: const Value(null),
            leaseUntil: const Value(null),
            lastErrorCode: Value(errorCode)),
        incrementAttempt: true);
  }

  @override
  Future<void> deadLetter(MutationLease lease, {required String errorCode}) =>
      _transition(
          lease,
          SyncOutboxCompanion(
              state: const Value('deadLetter'),
              leaseToken: const Value(null),
              leaseUntil: const Value(null),
              lastErrorCode: Value(errorCode)));
  Future<void> _transition(MutationLease lease, SyncOutboxCompanion values,
      {bool incrementAttempt = false}) async {
    final current = await (_db.select(_db.syncOutbox)
          ..where((r) =>
              r.mutationId.equals(lease.mutation.mutationId) &
              r.state.equals('leased') &
              r.leaseToken.equals(lease.leaseToken) &
              r.localRevision.equals(lease.leasedLocalRevision)))
        .getSingleOrNull();
    if (current == null) return;
    final update = incrementAttempt
        ? values.copyWith(attemptCount: Value(current.attemptCount + 1))
        : values;
    await (_db.update(_db.syncOutbox)
          ..where((r) =>
              r.mutationId.equals(lease.mutation.mutationId) &
              r.leaseToken.equals(lease.leaseToken) &
              r.localRevision.equals(lease.leasedLocalRevision)))
        .write(update);
  }

  @override
  Future<int> releaseExpiredLeases(DateTime now) => (_db.update(_db.syncOutbox)
        ..where((r) =>
            r.state.equals('leased') &
            r.leaseUntil.isSmallerThanValue(now.toUtc())))
      .write(SyncOutboxCompanion(
          state: const Value('pending'),
          leaseToken: const Value(null),
          leaseUntil: const Value(null)));

  @override
  Future<DateTime?> earliestPendingAttemptAt(
      {required String accountId}) async {
    final row = await (_db.select(_db.syncOutbox)
          ..where(
              (r) => r.accountId.equals(accountId) & r.state.equals('pending'))
          ..orderBy([(r) => OrderingTerm.asc(r.nextAttemptAt)])
          ..limit(1))
        .getSingleOrNull();
    return row?.nextAttemptAt.toUtc();
  }

  @override
  Future<List<SyncMutation>> peekPending(
      {required String accountId, required SyncDataset dataset}) async {
    final rows = await (_db.select(_db.syncOutbox)
          ..where((r) =>
              r.accountId.equals(accountId) &
              r.dataset.equals(dataset.stableId) &
              (r.state.equals('pending') | r.state.equals('leased'))))
        .get();
    return rows.map(_mutation).toList();
  }

  SyncMutation _mutation(SyncOutboxData row) => SyncMutation(
      mutationId: row.mutationId,
      accountId: row.accountId,
      dataset: SyncDataset.fromStableId(row.dataset),
      entityId: row.entityId,
      operation: SyncMutationOperation.values.byName(row.operation),
      payload: Map<String, Object?>.from(jsonDecode(row.payload) as Map),
      fieldMask: List<String>.from(jsonDecode(row.fieldMask) as List),
      payloadVersion: row.payloadVersion,
      localRevision: row.localRevision,
      clientUpdatedAt: row.clientUpdatedAt,
      baseRemoteRevision: row.baseRemoteRevision);
}
