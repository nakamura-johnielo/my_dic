import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_outbox_writer.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_sync_queue.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_sync_checkpoint_store.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';

SyncMutation mutation(
        {required String id,
        required int revision,
        String account = 'account-a',
        Map<String, Object?> payload = const {'learned': true},
        List<String> mask = const ['learned'],
        DateTime? clientUpdatedAt}) =>
    SyncMutation(
      mutationId: id,
      accountId: account,
      dataset: SyncDataset.espJpnWordStatus,
      entityId: 'word-1',
      operation: SyncMutationOperation.patch,
      payload: payload,
      fieldMask: mask,
      localRevision: revision,
      clientUpdatedAt: clientUpdatedAt ?? DateTime.utc(2026),
    );

void main() {
  late DatabaseProvider database;
  late DriftOutboxWriter writer;
  late DriftSyncQueue queue;

  setUp(() {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
    writer = DriftOutboxWriter(database, clock: () => DateTime.utc(2026));
    queue = DriftSyncQueue(database);
  });

  tearDown(() => database.close());

  test('coalesces only pending mutations while preserving changed fields',
      () async {
    await writer.enqueue(mutation(
      id: 'm1',
      revision: 1,
      clientUpdatedAt: DateTime.utc(2026, 8, 6),
    ));
    await writer.enqueue(mutation(
      id: 'm2',
      revision: 2,
      payload: {'bookmarked': true},
      mask: ['bookmarked'],
      clientUpdatedAt: DateTime.utc(2026, 8, 7),
    ));

    final rows = await database.select(database.syncOutbox).get();
    expect(rows, hasLength(1));
    expect(rows.single.localRevision, 2);
    expect(
        jsonDecode(rows.single.payload), {'learned': true, 'bookmarked': true});
    expect(jsonDecode(rows.single.fieldMask),
        containsAll(['learned', 'bookmarked']));
    expect(rows.single.clientUpdatedAt.toUtc(), DateTime.utc(2026, 8, 7));
  });

  test('persists the mutation client update time in UTC', () async {
    final clientUpdatedAt = DateTime(2026, 8, 7, 4, 5, 6);
    await writer.enqueue(
        mutation(id: 'm1', revision: 1, clientUpdatedAt: clientUpdatedAt));

    final row = await database.select(database.syncOutbox).getSingle();
    expect(row.clientUpdatedAt.toUtc(), clientUpdatedAt.toUtc());
    expect(
        (await queue.peekPending(
          accountId: 'account-a',
          dataset: SyncDataset.espJpnWordStatus,
        ))
            .single
            .clientUpdatedAt,
        clientUpdatedAt.toUtc());
  });

  test('ack requires both lease token and the leased revision', () async {
    await writer.enqueue(mutation(id: 'm1', revision: 1));
    final lease = (await queue.leasePending(
            accountId: 'account-a',
            dataset: SyncDataset.espJpnWordStatus,
            limit: 1,
            now: DateTime.utc(2026),
            leaseDuration: const Duration(minutes: 1)))
        .single;

    expect(await queue.ack(lease), isTrue);
    expect(await database.select(database.syncOutbox).get(), isEmpty);
  });

  test('never leases a different account', () async {
    await writer.enqueue(mutation(id: 'm1', revision: 1));
    expect(
        await queue.leasePending(
            accountId: 'account-b',
            dataset: SyncDataset.espJpnWordStatus,
            limit: 1,
            now: DateTime.utc(2026),
            leaseDuration: const Duration(minutes: 1)),
        isEmpty);
  });

  test('domain row and outbox roll back in the same Drift transaction',
      () async {
    await expectLater(
      database.transaction(() async {
        await database.into(database.myWords).insert(MyWordsCompanion.insert(
              myWordId: 'word-1',
              word: 'hola',
              editAt: '2026-01-01T00:00:00Z',
              accountId: const Value('account-a'),
            ));
        await writer.enqueue(mutation(id: 'm1', revision: 1));
        throw StateError('rollback');
      }),
      throwsStateError,
    );
    expect(await database.select(database.myWords).get(), isEmpty);
    expect(await database.select(database.syncOutbox).get(), isEmpty);
  });

  test('remote apply and checkpoint roll back together', () async {
    final checkpoints = DriftSyncCheckpointStore(database);
    await expectLater(
      database.transaction(() async {
        await database.into(database.myWords).insert(MyWordsCompanion.insert(
              myWordId: 'word-1',
              word: 'hola',
              editAt: '2026-01-01T00:00:00Z',
              accountId: const Value('account-a'),
            ));
        await checkpoints.write(
          accountId: 'account-a',
          dataset: SyncDataset.myWords,
          cursor: const SyncCursor(
              seconds: 1, nanoseconds: 0, documentId: 'word-1'),
          lastSuccessfulAt: DateTime.utc(2026),
        );
        throw StateError('rollback');
      }),
      throwsStateError,
    );
    expect(await database.select(database.myWords).get(), isEmpty);
    expect(await database.select(database.syncCheckpoints).get(), isEmpty);
  });

  test('a leased mutation is not coalesced and old ack keeps the new edit',
      () async {
    await writer.enqueue(mutation(id: 'm1', revision: 1));
    final lease = (await queue.leasePending(
      accountId: 'account-a',
      dataset: SyncDataset.espJpnWordStatus,
      limit: 1,
      now: DateTime.utc(2026),
      leaseDuration: const Duration(minutes: 1),
    ))
        .single;
    await writer.enqueue(mutation(id: 'm2', revision: 2));
    expect(await database.select(database.syncOutbox).get(), hasLength(2));
    expect(await queue.ack(lease), isTrue);
    final remaining = await database.select(database.syncOutbox).getSingle();
    expect(remaining.mutationId, 'm2');
    expect(remaining.localRevision, 2);
  });

  test('retry increments attempt and dead-letter is no longer leasable',
      () async {
    await writer.enqueue(mutation(id: 'm1', revision: 1));
    var lease = (await queue.leasePending(
      accountId: 'account-a',
      dataset: SyncDataset.espJpnWordStatus,
      limit: 1,
      now: DateTime.utc(2026),
      leaseDuration: const Duration(minutes: 1),
    ))
        .single;
    final retryAt = DateTime.utc(2026).add(const Duration(minutes: 1));
    await queue.retry(lease, errorCode: 'network', nextAttemptAt: retryAt);
    var row = await database.select(database.syncOutbox).getSingle();
    expect(row.attemptCount, 1);
    expect(row.state, 'pending');
    expect(
        await queue.leasePending(
          accountId: 'account-a',
          dataset: SyncDataset.espJpnWordStatus,
          limit: 1,
          now: DateTime.utc(2026),
          leaseDuration: const Duration(minutes: 1),
        ),
        isEmpty);
    lease = (await queue.leasePending(
      accountId: 'account-a',
      dataset: SyncDataset.espJpnWordStatus,
      limit: 1,
      now: retryAt,
      leaseDuration: const Duration(minutes: 1),
    ))
        .single;
    await queue.deadLetter(lease, errorCode: 'schema');
    row = await database.select(database.syncOutbox).getSingle();
    expect(row.state, 'deadLetter');
    expect(
        await queue.leasePending(
          accountId: 'account-a',
          dataset: SyncDataset.espJpnWordStatus,
          limit: 1,
          now: retryAt,
          leaseDuration: const Duration(minutes: 1),
        ),
        isEmpty);
  });
}
