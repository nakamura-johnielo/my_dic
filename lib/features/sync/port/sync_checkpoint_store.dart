import 'model/sync_cursor.dart';
import 'sync_dataset.dart';

abstract interface class SyncCheckpointStore {
  Future<SyncCursor?> read(
      {required String accountId, required SyncDataset dataset});
  Future<void> write(
      {required String accountId,
      required SyncDataset dataset,
      required SyncCursor cursor,
      required DateTime lastSuccessfulAt});
}
