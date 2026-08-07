import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/port/sync_queue.dart';

abstract interface class SyncQueueHarness {
  SyncQueue get queue;
  Future<void> enqueue(SyncMutation mutation);
  Future<void> close();
}

SyncMutation contractMutation(String id,
        {String accountId = 'a', int revision = 1}) =>
    SyncMutation(
      mutationId: id,
      accountId: accountId,
      dataset: SyncDataset.myWords,
      entityId: id,
      operation: SyncMutationOperation.upsert,
      payload: {'id': id},
      fieldMask: const ['id'],
      localRevision: revision,
      clientUpdatedAt: DateTime.utc(2026),
    );

void syncQueueContract(
    String name, Future<SyncQueueHarness> Function() create) {
  group('$name SyncQueue contract', () {
    late SyncQueueHarness harness;
    setUp(() async => harness = await create());
    tearDown(() => harness.close());

    test('leases FIFO within account and dataset only', () async {
      await harness.enqueue(contractMutation('a1'));
      await harness.enqueue(contractMutation('b1', accountId: 'b'));
      final leases = await harness.queue.leasePending(
          accountId: 'a',
          dataset: SyncDataset.myWords,
          limit: 10,
          now: DateTime.utc(2026),
          leaseDuration: const Duration(minutes: 1));
      expect(leases.map((e) => e.mutation.mutationId), ['a1']);
    });

    test('ack is protected by lease token and revision', () async {
      await harness.enqueue(contractMutation('m1', revision: 2));
      final lease = (await harness.queue.leasePending(
              accountId: 'a',
              dataset: SyncDataset.myWords,
              limit: 1,
              now: DateTime.utc(2026),
              leaseDuration: const Duration(minutes: 1)))
          .single;
      expect(await harness.queue.ack(lease), isTrue);
      expect(await harness.queue.ack(lease), isFalse);
    });

    test('expired lease becomes pending again', () async {
      await harness.enqueue(contractMutation('m1'));
      await harness.queue.leasePending(
          accountId: 'a',
          dataset: SyncDataset.myWords,
          limit: 1,
          now: DateTime.utc(2026),
          leaseDuration: const Duration(seconds: 1));
      expect(
          await harness.queue.releaseExpiredLeases(
              DateTime.utc(2026).add(const Duration(seconds: 2))),
          1);
      final leases = await harness.queue.leasePending(
          accountId: 'a',
          dataset: SyncDataset.myWords,
          limit: 1,
          now: DateTime.utc(2026).add(const Duration(seconds: 2)),
          leaseDuration: const Duration(minutes: 1));
      expect(leases.single.mutation.mutationId, 'm1');
    });

    test('retry increments attempt and waits until nextAttemptAt', () async {
      final now = DateTime.utc(2026);
      await harness.enqueue(contractMutation('m1'));
      final first = (await harness.queue.leasePending(
        accountId: 'a',
        dataset: SyncDataset.myWords,
        limit: 1,
        now: now,
        leaseDuration: const Duration(minutes: 1),
      ))
          .single;
      expect(first.attemptCount, 0);

      final retryAt = now.add(const Duration(seconds: 30));
      await harness.queue.retry(
        first,
        errorCode: 'network',
        nextAttemptAt: retryAt,
      );
      expect(
        await harness.queue.leasePending(
          accountId: 'a',
          dataset: SyncDataset.myWords,
          limit: 1,
          now: now.add(const Duration(seconds: 29)),
          leaseDuration: const Duration(minutes: 1),
        ),
        isEmpty,
      );

      final second = (await harness.queue.leasePending(
        accountId: 'a',
        dataset: SyncDataset.myWords,
        limit: 1,
        now: retryAt,
        leaseDuration: const Duration(minutes: 1),
      ))
          .single;
      expect(second.attemptCount, 1);
    });
  });
}
