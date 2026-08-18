import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_device_local_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/shared_preferences_user_dao.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/local_user_dto.dart';

final class SharedPreferencesUserDataSource
    implements UserDeviceLocalDataSource {
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
