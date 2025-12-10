import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/riverpod.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/user/app_auth.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/user/profile.dart';

final authEffectProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AppAuth?>>(
    authStreamProvider,
    (previous, next) async {
      // ログアウト時クリーンアップ
      if (next.value == null) {
        final input = AppAuth(userId: 'logout');
        ref.read(userViewModelProvider.notifier).setAuthInfo(input);
        ref.read(wordStatusSyncServiceProvider).dispose();
        return;
      }
      print("~~~~~~~~~~");
      print(" auth effect");
      print("user valid");
      final appAuth = next.value!;
      // ログイン後、ユーザー情報リロード
      await ref.read(userViewModelProvider.notifier).getUser(appAuth.userId);
      ref.read(userViewModelProvider.notifier).setAuthInfo(appAuth);

      // lastSync取得
      final syncDao = ref.read(syncStatusDaoProvider);
      final stored = await syncDao.getLastSync('lastSync_wordStatus');

      final startPoint =
          stored ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

      ref.read(wordStatusSyncServiceProvider).startSync(
        appAuth.userId,
        startPoint,
        (newLastSync) async {
          await syncDao.setLastSync('lastSync_wordStatus', newLastSync);
          ref.read(setLastSyncProvider('lastSync_wordStatus'))(newLastSync);
        },
      );
    },
  );
});
