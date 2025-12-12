import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/riverpod.dart';
import 'package:my_dic/core/common/enums/subscription_status.dart';
import 'package:my_dic/features/auth/di/data_di.dart';
import 'package:my_dic/features/auth/di/view_model_di.dart';
import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/features/user/di/viewmodel.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';

final authStreamProvider = StreamProvider<AppAuth?>((ref) {
  final useCase = ref.read(observeAuthStateUseCaseProvider);
  return useCase.execute();
});

// ...existing code...

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

      final appAuth = next.value!;

      // 新規ユーザー登録の検出（previousがnullでnextがある場合）
      final isNewSignUp = previous?.value == null && next.value != null;

      if (isNewSignUp) {
        // 新規ユーザーのProfile作成
        final user = AppUser(
          id: appAuth.userId,
          email: appAuth.email,
          username: appAuth.email?.split('@')[0] ?? 'Anonymous User',
          subscriptionStatus: SubscriptionStatus.trial,
        );

        try {
          await ref.read(userViewModelProvider.notifier).createUser(user);
          await ref.read(authViewModelProvider.notifier).VerifyEmail();
        } catch (e) {
          print('Failed to create user profile: $e');
        }
      }

      // 既存のユーザー情報ロード
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

// final authEffectProvider = Provider<void>((ref) {
//   ref.listen<AsyncValue<AppAuth?>>(
//     authStreamProvider,
//     (previous, next) async {
//       // ログアウト時クリーンアップ
//       if (next.value == null) {
//         final input = AppAuth(userId: 'logout');
//         ref.read(userViewModelProvider.notifier).setAuthInfo(input);
//         ref.read(wordStatusSyncServiceProvider).dispose();
//         return;
//       }
//       print("~~~~~~~~~~");
//       print(" auth effect");
//       print("user valid");
//       final appAuth = next.value!;
//       // ログイン後、ユーザー情報リロード
//       await ref.read(userViewModelProvider.notifier).getUser(appAuth.userId);
//       ref.read(userViewModelProvider.notifier).setAuthInfo(appAuth);

//       // lastSync取得
//       final syncDao = ref.read(syncStatusDaoProvider);
//       final stored = await syncDao.getLastSync('lastSync_wordStatus');

//       final startPoint =
//           stored ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

//       ref.read(wordStatusSyncServiceProvider).startSync(
//         appAuth.userId,
//         startPoint,
//         (newLastSync) async {
//           await syncDao.setLastSync('lastSync_wordStatus', newLastSync);
//           ref.read(setLastSyncProvider('lastSync_wordStatus'))(newLastSync);
//         },
//       );
//     },
//   );
// });
