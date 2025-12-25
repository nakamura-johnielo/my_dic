import 'package:my_dic/core/common/consts/dates.dart';
import 'package:my_dic/core/domain/i_repository/i_sync_status_repository.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/shared_preferences_syncstatus_dao.dart';

class SharedPreferenceSyncStatusRepository implements ISyncStatusRepository {
  // final FirebaseWordStatusDao _remote;
  final SharedPreferencesSyncStatusDao _repository;
  SharedPreferenceSyncStatusRepository(this._repository);

  @override
  Future<DateTime?> getLastSyncDate() async {
    print("lastsync: ${await _repository.getLastSyncDate()}");
    //return DateTime(1999,1,11);//TODO fix
    return await _repository.getLastSyncDate();
  }

  @override
  Future<void> updateSyncDate(DateTime date) async {
    await _repository.updateLastSyncDate(date);
    print("lastsync updated: ${await _repository.getLastSyncDate()}");
  }
}
