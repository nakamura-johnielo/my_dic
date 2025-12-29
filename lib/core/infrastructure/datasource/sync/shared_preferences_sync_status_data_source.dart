import 'package:my_dic/core/infrastructure/database/shared_preferences/shared_preferences_syncstatus_dao.dart';

import 'i_sync_status_data_source.dart';

class SharedPreferencesSyncStatusDataSource implements ISyncStatusDataSource {
  final SharedPreferencesSyncStatusDao _dao;
  SharedPreferencesSyncStatusDataSource(this._dao);

  @override
  Future<DateTime?> getLastSyncDate() async {
    return await _dao.getLastSyncDate();
  }

  @override
  Future<void> updateSyncDate(DateTime date) async {
    await _dao.updateLastSyncDate(date);
  }
}
