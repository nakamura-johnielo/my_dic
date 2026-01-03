import 'package:my_dic/core/infrastructure/database/shared_preferences/shared_preferences_syncstatus_dao.dart';
import 'package:my_dic/features/user/data/data_source/local/i_user_local_data_source.dart';
import 'package:my_dic/features/user/data/data_source/local/shared_preferenced_user_dao.dart';
import 'package:my_dic/features/user/data/dto/local_user_dto.dart';

class SharedPreferencesUserDataSource implements IUserLocalDataSource {
  final SharedPreferencesUserDao _dao;
  SharedPreferencesUserDataSource(this._dao);

  @override
  Future<LocalUserDTO?> getUser() async {
    final deviceId = await _dao.getDeviceId();
    if (deviceId == null) return null;
    return LocalUserDTO(deviceId: deviceId);
  }

  @override
  Future<void> updateUser(LocalUserDTO user) async {
    await _dao.updateDeviceId(user.deviceId);
  }
}
