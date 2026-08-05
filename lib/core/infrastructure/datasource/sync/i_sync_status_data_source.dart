import 'package:my_dic/core/domain/entity/sync_checkpoint.dart';

abstract class ISyncStatusDataSource {
  Future<SyncCheckpoint?> getCheckpoint(SyncCheckpointKey key);
  Future<void> saveCheckpoint(SyncCheckpoint checkpoint);
}
