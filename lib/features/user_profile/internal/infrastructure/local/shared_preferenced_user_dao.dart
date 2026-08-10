import 'package:my_dic/core/shared/consts/shared_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUserDao {
  final  SharedPreferences prefs;
  final String _deviceIdkey = SharedPreferenceKeys.deviceId;

  SharedPreferencesUserDao(this.prefs);

  Future<String?> getDeviceId() async {
    final userData = prefs.getString(_deviceIdkey);
    if (userData == null) return null;
    return userData;
  }

  Future<void> updateDeviceId(String deviceId) async {
    await prefs.setString(_deviceIdkey, deviceId);
  }
}
