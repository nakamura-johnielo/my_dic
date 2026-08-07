import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/features/sync/sync_service.dart';

//TODO userid aync 調整
// Esp-Jpn/Jpn-Esp word status, MyWord, and MyWordStatus no longer run through
// the legacy SyncService: they are pushed/pulled by their respective
// `DatasetSyncHandler`s via the new SyncEngine (see
// app/bootstrap/sync_composition.dart and lifecycle_effects.dart).
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService([]);
});

final _syncWithRemoteProvider = Provider.autoDispose<void>((ref) {
  final service = ref.read(syncServiceProvider);
  final sub = service.startSyncWithRemote();

  ref.onDispose(() {
    sub.cancel();
  });
});

// ラッパープロバイダーで自動化
final autoSyncProvider = Provider.autoDispose<void>((ref) {
  final isReady = ref.watch(appSessionProvider) is AppSessionReady;
  if (!isReady) return;

  // userId は usecase 内で解決する
  ref.watch(_syncWithRemoteProvider);
});
