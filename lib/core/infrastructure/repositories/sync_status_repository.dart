import 'package:my_dic/core/domain/entity/sync_checkpoint.dart';
import 'package:my_dic/core/domain/i_repository/i_sync_status_repository.dart';
import 'package:my_dic/core/infrastructure/datasource/sync/i_sync_status_data_source.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';

class SyncStatusRepository implements ISyncStatusRepository {
  final ISyncStatusDataSource _dataSource;
  SyncStatusRepository(this._dataSource);

  @override
  Future<Result<SyncCheckpoint?>> getCheckpoint(SyncCheckpointKey key) async {
    try {
      return Result.success(await _dataSource.getCheckpoint(key));
    } catch (e, stackTrace) {
      return Result.failure(CacheError(
        message: '最終同期日時の取得に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<void>> saveCheckpoint(SyncCheckpoint checkpoint) async {
    try {
      await _dataSource.saveCheckpoint(checkpoint);
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(CacheError(
        message: '最終同期日時の更新に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
