import 'package:my_dic/core/common/consts/sharedPreference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesSyncStatusDao {
  final String _key=SharedPreferenceKeys.lastSyncKey;

  Future<DateTime?> getLastSyncDate() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_key);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  Future<void> updateLastSyncDate(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, dateTime.toUtc().millisecondsSinceEpoch);
  }
}
