import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/di/service.dart';
import 'package:my_dic/features/esp_jpn_word_status/di/di.dart';
import 'package:my_dic/features/my_word/di/usecase_di.dart';
import 'package:my_dic/features/sync/sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService([
    ref.read(syncEspJpnWordStatusUseCaseProvider),
    ref.read(syncMyWordUseCaseProvider),
    ref.read(syncMyWordStatusUseCaseProvider),
  ]);
});

//userIdで
final _syncWithRemoteProvider =
    Provider.autoDispose.family<void, String>((ref, userId) {
  if (userId.isEmpty) {
    return;
  }

  final service = ref.read(syncServiceProvider);
  final sub = service.startSyncWithRemote(userId);

  ref.onDispose(() {
    sub.cancel();
  });
});

// ラッパープロバイダーで自動化
final autoSyncProvider = Provider.autoDispose<void>((ref) {
  // isAuthenticated を監視（false → プロバイダーは早期 return して停止）
  final isAuth = ref.watch(
      authStoreNotifierProvider.select((a) => a?.isAuthenticated ?? false));
  if (!isAuth) return;

  final userId =
      ref.watch(authStoreNotifierProvider.select((a) => a?.accountId));

  if (userId == null ||
      userId.isEmpty ||
      userId != "logout" ||
      userId != "anonymous") {
    return;
  }

  // familyプロバイダーを呼び出し
  ref.watch(_syncWithRemoteProvider(userId));
});
