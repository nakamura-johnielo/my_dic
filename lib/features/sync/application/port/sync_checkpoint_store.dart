import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';

abstract interface class SyncCheckpointStore {
  Future<SyncCursor?> read(
      {required String accountId, required SyncDataset dataset});
  Future<void> write(
      {required String accountId,
      required SyncDataset dataset,
      required SyncCursor cursor,
      required DateTime lastSuccessfulAt});
}
