
import 'package:my_dic/core/domain/i_repository/i_sync_status_repository.dart';
import 'package:my_dic/core/infrastructure/database/shared_preferences/shared_preferences_syncstatus_dao.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';

class SharedPreferenceSyncStatusRepository implements ISyncStatusRepository {
  // final FirebaseWordStatusDao _remote;
  final SharedPreferencesSyncStatusDao _repository;
  SharedPreferenceSyncStatusRepository(this._repository);

  @override
  Future<Result<DateTime?>> getLastSyncDate() async {
    try {
      final date = await _repository.getLastSyncDate();
      print("lastsync: $date");
      //return DateTime(1999,1,11);//TODO fix
      return Result.success(date);
    } catch (e, stackTrace) {
      return Result.failure(CacheError(
        message: '最終同期日時の取得に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<void>> updateSyncDate(DateTime date) async {
    try {
      await _repository.updateLastSyncDate(date);
      print("lastsync updated: ${await _repository.getLastSyncDate()}");
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
