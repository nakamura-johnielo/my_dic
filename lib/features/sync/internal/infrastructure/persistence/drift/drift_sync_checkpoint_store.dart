import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/port/model/sync_cursor.dart';
import 'package:my_dic/features/sync/port/sync_checkpoint_store.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';

class DriftSyncCheckpointStore implements SyncCheckpointStore {
  DriftSyncCheckpointStore(this._db);
  final DatabaseProvider _db;
  @override
  Future<SyncCursor?> read(
      {required String accountId, required SyncDataset dataset}) async {
    final query = _db.select(_db.syncCheckpoints)
      ..where((row) =>
          row.accountId.equals(accountId) &
          row.dataset.equals(dataset.stableId));
    final row = await query.getSingleOrNull();
    return row == null
        ? null
        : SyncCursor(
            seconds: row.cursorSeconds,
            nanoseconds: row.cursorNanoseconds,
            documentId: row.cursorDocumentId);
  }

  @override
  Future<void> write(
          {required String accountId,
          required SyncDataset dataset,
          required SyncCursor cursor,
          required DateTime lastSuccessfulAt}) =>
      _db.into(_db.syncCheckpoints).insertOnConflictUpdate(
          SyncCheckpointsCompanion.insert(
              accountId: accountId,
              dataset: dataset.stableId,
              cursorSeconds: cursor.seconds,
              cursorNanoseconds: cursor.nanoseconds,
              cursorDocumentId: cursor.documentId,
              lastSuccessfulAt: lastSuccessfulAt.toUtc()));
}
