import 'package:shared_preferences/shared_preferences.dart';

/// Minimal preferences surface used by the one-time legacy sync cleanup.
///
/// It intentionally exposes no value-reading APIs: legacy cursors must never
/// be copied into the Drift-backed sync engine.
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

/// Removes obsolete SharedPreferences sync cursors during the Release A
/// upgrade. A completed marker makes the operation one-shot per installation.
class LegacySyncPreferencesCleanup {
  const LegacySyncPreferencesCleanup();

  static const completionMarker = 'legacy_sync_cleanup.v1.completed';
  static const _legacyGlobalKey = 'lastSync_wordStatus';
  static const _legacyCheckpointPrefix = 'sync_checkpoint.v1.';

  /// Returns whether the cleanup is known to have completed.
  ///
  /// Cleanup errors are deliberately non-fatal. Without the marker a later
  /// launch retries, while the new engine starts and performs a full pull.
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
