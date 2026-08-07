import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/port/outbox_writer.dart';

class DriftOutboxWriter implements OutboxWriter {
  DriftOutboxWriter(this._db, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;
  final DatabaseProvider _db;
  final DateTime Function() _clock;
  @override
  Future<void> enqueue(EnqueueMutation mutation) => _db.transaction(() async {
        final now = _clock().toUtc();
        final pending = await (_db.select(_db.syncOutbox)
              ..where((row) =>
                  row.accountId.equals(mutation.accountId) &
                  row.dataset.equals(mutation.dataset.stableId) &
                  row.entityId.equals(mutation.entityId) &
                  row.state.equals('pending'))
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)])
              ..limit(1))
            .getSingleOrNull();
        if (pending != null) {
          final oldPayload =
              Map<String, Object?>.from(jsonDecode(pending.payload) as Map);
          final payload = <String, Object?>{...oldPayload, ...mutation.payload};
          final fieldMask = <String>{
            ...List<String>.from(jsonDecode(pending.fieldMask) as List),
            ...mutation.fieldMask,
          }.toList(growable: false);
          await (_db.update(_db.syncOutbox)
                ..where((row) => row.mutationId.equals(pending.mutationId)))
              .write(
            SyncOutboxCompanion(
              operation: Value(mutation.operation.name),
              payload: Value(jsonEncode(payload)),
              fieldMask: Value(jsonEncode(fieldMask)),
              payloadVersion: Value(mutation.payloadVersion),
              localRevision: Value(mutation.localRevision),
              baseRemoteRevision: Value(mutation.baseRemoteRevision),
              clientUpdatedAt: Value(mutation.clientUpdatedAt),
              nextAttemptAt: Value(now),
              lastErrorCode: const Value(null),
            ),
          );
          return;
        }
        await _db.into(_db.syncOutbox).insert(
              SyncOutboxCompanion.insert(
                mutationId: mutation.mutationId,
                accountId: mutation.accountId,
                dataset: mutation.dataset.stableId,
                entityId: mutation.entityId,
                operation: mutation.operation.name,
                payload: jsonEncode(mutation.payload),
                fieldMask: jsonEncode(mutation.fieldMask),
                payloadVersion: mutation.payloadVersion,
                localRevision: mutation.localRevision,
                baseRemoteRevision: Value(mutation.baseRemoteRevision),
                state: 'pending',
                nextAttemptAt: now,
                createdAt: now,
                clientUpdatedAt: mutation.clientUpdatedAt,
              ),
            );
      });
}
