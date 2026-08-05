import 'package:my_dic/core/domain/entity/sync_checkpoint.dart';
import 'package:my_dic/core/infrastructure/database/shared_preferences/shared_preferences_syncstatus_dao.dart';

import 'i_sync_status_data_source.dart';

class SharedPreferencesSyncStatusDataSource implements ISyncStatusDataSource {
  final SharedPreferencesSyncStatusDao _dao;
  SharedPreferencesSyncStatusDataSource(this._dao);

  @override
  Future<SyncCheckpoint?> getCheckpoint(SyncCheckpointKey key) async {
    return _dao.getCheckpoint(key);
  }

  @override
  Future<void> saveCheckpoint(SyncCheckpoint checkpoint) async {
    await _dao.saveCheckpoint(checkpoint);
  }
}
