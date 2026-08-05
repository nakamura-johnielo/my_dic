import 'package:my_dic/core/domain/entity/sync_checkpoint.dart';
import 'package:my_dic/core/shared/utils/result.dart';

abstract class ISyncStatusRepository {
  Future<Result<SyncCheckpoint?>> getCheckpoint(SyncCheckpointKey key);
  Future<Result<void>> saveCheckpoint(SyncCheckpoint checkpoint);
}
