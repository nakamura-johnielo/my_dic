import 'package:my_dic/core/shared/consts/sharedPreference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesSyncStatusDao {
  final SharedPreferences prefs;
  final String _key=SharedPreferenceKeys.lastSyncDate;

  SharedPreferencesSyncStatusDao(this.prefs);

  Future<DateTime?> getLastSyncDate() async {
    final millis = prefs.getInt(_key);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  Future<void> updateLastSyncDate(DateTime dateTime) async {
    await prefs.setInt(_key, dateTime.toUtc().millisecondsSinceEpoch);
  }
}
