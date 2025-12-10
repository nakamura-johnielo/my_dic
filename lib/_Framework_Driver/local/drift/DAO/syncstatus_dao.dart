import 'package:shared_preferences/shared_preferences.dart';

class SyncStatusDao {
  Future<DateTime?> getLastSync(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(key);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  Future<void> setLastSync(String key, DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, dateTime.toUtc().millisecondsSinceEpoch);
  }
}
