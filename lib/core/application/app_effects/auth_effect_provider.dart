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

/// 認証状態の変化を監視し、副作用を実行
final authEffectProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AppAuth?>>(
    authStreamProvider,
    (previous, next) async {
      await _handleAuthStateChange(ref, previous?.value, next.value);
    },
  );
});

/// 認証状態変化のハンドラー（処理を分離）
Future<void> _handleAuthStateChange(
  Ref ref,
  AppAuth? previousAuth,
  AppAuth? currentAuth,
) async {
  // ログアウト処理
  if (currentAuth == null) {
    await _handleSignOut(ref, previousAuth);
    return;
  }

  // ログイン処理
  await _handleSignIn(ref, currentAuth);
}

/// サインアウト時の処理
Future<void> _handleSignOut(Ref ref, AppAuth? previousAuth) async {
  print('[Auth Effect] User signed out');

  // ViewModelの状態をクリア
  if (previousAuth != null) {
    ref.read(userViewModelProvider.notifier).setAuthInfo(
          AppAuth(userId: 'logout', isLogined: false),
        );
  }

  // 同期サービスを停止
  ref.read(wordStatusSyncServiceProvider).dispose();
}

/// サインイン時の処理
Future<void> _handleSignIn(Ref ref, AppAuth currentAuth) async {
  print('[Auth Effect] User signed in: ${currentAuth.userId}');

  try {
    // 2. ユーザー情報をロード
    await ref.read(userViewModelProvider.notifier).loadUser(currentAuth.userId);

    // 3. 認証情報を同期
    ref.read(userViewModelProvider.notifier).setAuthInfo(currentAuth);

    // 4. 同期サービスを開始
    await _startSyncService(ref, currentAuth.userId);
  } catch (e) {
    print('[Auth Effect] Error during sign in: $e');
    // エラーハンドリング（必要に応じてUIにエラーを通知）
  }
}

/// 新規ユーザー登録時の処理
// Future<void> _handleNewUserSignUp(Ref ref, AppAuth auth) async {
//   print('[Auth Effect] Creating new user profile: ${auth.userId}');

//   final newUser = AppUser(
//     id: auth.userId,
//     email: auth.email,
//     username: auth.email?.split('@')[0] ?? 'User',
//     subscriptionStatus: SubscriptionStatus.trial,
//   );

//   try {
//     // ユーザープロファイル作成
//     await ref.read(userViewModelProvider.notifier).updateUser(newUser);

//     // メール認証送信
//     if (!auth.isVerified) {
//       await ref.read(authViewModelProvider.notifier).verifyEmail();
//       print('[Auth Effect] Verification email sent');
//     }
//   } catch (e) {
//     print('[Auth Effect] Failed to create user profile: $e');
//     rethrow;
//   }
// }

/// 同期サービスの開始
Future<void> _startSyncService(Ref ref, String userId) async {
  final syncDao = ref.read(syncStatusDaoProvider);
  final lastSync = await syncDao.getLastSync('lastSync_wordStatus');

  final startPoint =
      lastSync ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  ref.read(wordStatusSyncServiceProvider).startSync(
    userId,
    startPoint,
    (newLastSync) async {
      await syncDao.setLastSync('lastSync_wordStatus', newLastSync);
      ref.read(setLastSyncProvider('lastSync_wordStatus'))(newLastSync);
    },
  );

  print('[Auth Effect] Sync service started from: $startPoint');
}

final authEffectProvider2 = Provider<void>((ref) {
  ref.listen<AsyncValue<AppAuth?>>(
    authStreamProvider,
    (previous, next) async {
      // ログアウト時クリーンアップ
      if (next.value == null) {
        final input = previous?.value ?? AppAuth(userId: 'logout');
        ref.read(userViewModelProvider.notifier).setAuthInfo(input);
        ref.read(wordStatusSyncServiceProvider).dispose();
        return;
      }

      final appAuth = next.value!;

      // 新規ユーザー登録の検出（previousがnullでnextがある場合）
      // final isNewSignUp = previous?.value == null && next.value != null;
      // まず既存のユーザー情報を取得
      final existingUser = await ref
          .read(userViewModelProvider.notifier)
          .loadUser(appAuth.userId);

      if (existingUser.id.isEmpty) {
        // 新規ユーザーのProfile作成
        final user = AppUser(
          id: appAuth.userId,
          email: appAuth.email,
          username: appAuth.email?.split('@')[0] ?? 'Anonymous User',
          subscriptionStatus: SubscriptionStatus.trial,
        );

        try {
          await ref.read(userViewModelProvider.notifier).createUser(user);
          await ref.read(authViewModelProvider.notifier).verifyEmail();
        } catch (e) {
          print('Failed to create user profile: $e');
        }
      }

      // 既存のユーザー情報ロード
      await ref.read(userViewModelProvider.notifier).loadUser(appAuth.userId);
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
