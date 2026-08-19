import 'package:shared_preferences/shared_preferences.dart';

/// 一度限りの旧同期クリーンアップで使用する最小限の設定インターフェース。
///
/// 意図的に値読み取りAPIは公開しません。旧カーソルをDriftベースの同期エンジンへコピーしては
/// いけません。
abstract interface class LegacySyncPreferencesStore {
  bool containsKey(String key);
  Iterable<String> getKeys();
  Future<bool> remove(String key);
  Future<bool> setBool(String key, bool value);
}

class SharedPreferencesLegacySyncPreferencesStore
    implements LegacySyncPreferencesStore {
  const SharedPreferencesLegacySyncPreferencesStore(this._preferences);

  final SharedPreferences _preferences;

  @override
  bool containsKey(String key) => _preferences.containsKey(key);

  @override
  Iterable<String> getKeys() => _preferences.getKeys();

  @override
  Future<bool> remove(String key) => _preferences.remove(key);

  @override
  Future<bool> setBool(String key, bool value) =>
      _preferences.setBool(key, value);
}

/// リリースAへの更新時に、古いSharedPreferences同期カーソルを削除します。完了マーカーにより
/// この操作はインストールごとに一度だけ実行されます。
class LegacySyncPreferencesCleanup {
  const LegacySyncPreferencesCleanup();

  static const completionMarker = 'legacy_sync_cleanup.v1.completed';
  static const _legacyGlobalKey = 'lastSync_wordStatus';
  static const _legacyCheckpointPrefix = 'sync_checkpoint.v1.';

  /// クリーンアップが完了済みと判明しているかを返します。
  ///
  /// クリーンアップエラーは意図的に致命的扱いしません。マーカーがなければ次回起動時に再試行し、
  /// 新しいエンジンは開始して全件取得を実行します。
  Future<bool> run(LegacySyncPreferencesStore preferences) async {
    try {
      if (preferences.containsKey(completionMarker)) {
        return true;
      }

      final keysToRemove = preferences
          .getKeys()
          .where(
            (key) =>
                key == _legacyGlobalKey ||
                key.startsWith(_legacyCheckpointPrefix),
          )
          .toList(growable: false);

      for (final key in keysToRemove) {
        if (!await preferences.remove(key)) {
          throw StateError('Could not remove legacy sync preference: $key');
        }
      }

      if (!await preferences.setBool(completionMarker, true)) {
        throw StateError('Could not write legacy sync cleanup marker');
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
