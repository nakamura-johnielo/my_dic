import 'dart:convert';

import 'package:my_dic/core/domain/entity/sync_checkpoint.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesSyncStatusDao {
  static const _namespace = 'sync_checkpoint.v1';
  static const _legacyGlobalKey = 'lastSync_wordStatus';

  final SharedPreferences prefs;

  SharedPreferencesSyncStatusDao(this.prefs);

  Future<SyncCheckpoint?> getCheckpoint(SyncCheckpointKey key) async {
    await _discardUnsafeLegacyCheckpoint();
    final encoded = prefs.getString(_storageKey(key));
    if (encoded == null) return null;

    final json = jsonDecode(encoded) as Map<String, dynamic>;
    return SyncCheckpoint(
      key: key,
      lastSuccessfulAt: DateTime.fromMillisecondsSinceEpoch(
        json['lastSuccessfulAt'] as int,
        isUtc: true,
      ),
      remoteCursor: json['remoteCursor'] as String?,
    );
  }

  Future<void> saveCheckpoint(SyncCheckpoint checkpoint) async {
    await _discardUnsafeLegacyCheckpoint();
    final encoded = jsonEncode({
      'lastSuccessfulAt':
          checkpoint.lastSuccessfulAt.toUtc().millisecondsSinceEpoch,
      if (checkpoint.remoteCursor != null)
        'remoteCursor': checkpoint.remoteCursor,
    });
    final saved = await prefs.setString(_storageKey(checkpoint.key), encoded);
    if (!saved) {
      throw StateError('Failed to persist sync checkpoint');
    }
  }

  String _storageKey(SyncCheckpointKey key) {
    final account = Uri.encodeComponent(key.accountId);
    return '$_namespace.$account.${key.dataset.stableId}';
  }

  Future<void> _discardUnsafeLegacyCheckpoint() async {
    if (!prefs.containsKey(_legacyGlobalKey)) return;
    final removed = await prefs.remove(_legacyGlobalKey);
    if (!removed) {
      throw StateError('Failed to remove legacy global sync checkpoint');
    }
  }
}
