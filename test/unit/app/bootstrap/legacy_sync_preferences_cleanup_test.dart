import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/bootstrap/legacy_sync_preferences_cleanup.dart';

void main() {
  test(
      'deletes every legacy key without reading its values then marks complete',
      () async {
    final preferences = _FakePreferences({
      'lastSync_wordStatus': 123,
      'sync_checkpoint.v1.user-a.wordStatus': 'legacy cursor',
      'sync_checkpoint.v1.user-b.myWords': 'another cursor',
      'unrelated': 'kept',
    });

    final completed =
        await const LegacySyncPreferencesCleanup().run(preferences);

    expect(completed, isTrue);
    expect(preferences.values, {
      'unrelated': 'kept',
      LegacySyncPreferencesCleanup.completionMarker: true,
    });
    expect(preferences.valueReadCount, 0);
  });

  test('is one-shot after its completion marker exists', () async {
    final preferences = _FakePreferences({
      LegacySyncPreferencesCleanup.completionMarker: true,
      'sync_checkpoint.v1.user-a.wordStatus': 'legacy cursor',
    });

    final completed =
        await const LegacySyncPreferencesCleanup().run(preferences);

    expect(completed, isTrue);
    expect(preferences.removedKeys, isEmpty);
    expect(preferences.setCalls, 0);
  });

  test('leaves marker absent on a delete failure so the next launch retries',
      () async {
    final preferences = _FakePreferences({
      'lastSync_wordStatus': 123,
      'sync_checkpoint.v1.user-a.wordStatus': 'legacy cursor',
    })
      ..failingRemovals.add('sync_checkpoint.v1.user-a.wordStatus');
    const cleanup = LegacySyncPreferencesCleanup();

    expect(await cleanup.run(preferences), isFalse);
    expect(
      preferences.containsKey(LegacySyncPreferencesCleanup.completionMarker),
      isFalse,
    );

    preferences.failingRemovals.clear();
    expect(await cleanup.run(preferences), isTrue);
    expect(
      preferences.containsKey(LegacySyncPreferencesCleanup.completionMarker),
      isTrue,
    );
  });

  test('leaves marker absent when writing it fails', () async {
    final preferences = _FakePreferences({'lastSync_wordStatus': 123})
      ..failMarkerWrite = true;

    expect(
      await const LegacySyncPreferencesCleanup().run(preferences),
      isFalse,
    );
    expect(
      preferences.containsKey(LegacySyncPreferencesCleanup.completionMarker),
      isFalse,
    );
  });
}

class _FakePreferences implements LegacySyncPreferencesStore {
  _FakePreferences(Map<String, Object> initialValues)
      : values = Map<String, Object>.from(initialValues);

  final Map<String, Object> values;
  final Set<String> failingRemovals = {};
  final List<String> removedKeys = [];
  var failMarkerWrite = false;
  var setCalls = 0;
  var valueReadCount = 0;

  @override
  bool containsKey(String key) => values.containsKey(key);

  @override
  Iterable<String> getKeys() => values.keys.toList(growable: false);

  @override
  Future<bool> remove(String key) async {
    removedKeys.add(key);
    if (failingRemovals.contains(key)) return false;
    values.remove(key);
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    setCalls++;
    if (failMarkerWrite) return false;
    values[key] = value;
    return true;
  }
}
