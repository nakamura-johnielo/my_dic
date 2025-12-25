import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/service/riverpod.dart';
import 'package:my_dic/core/common/enums/subscription_status.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/di/service/sync.dart';
import 'package:my_dic/features/auth/di/data_di.dart';
import 'package:my_dic/features/auth/di/view_model_di.dart';
import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/features/user/di/viewmodel.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';

/// 認証状態のストリームプロバイダー
/// Authを常に監視
final authStreamProvider = StreamProvider<AppAuth?>((ref) {
  final useCase = ref.read(observeAuthStateUseCaseProvider);
  return useCase.execute().distinct((prev, next) {
    // userId と isLogined が両方同じなら重複とみなす
    return prev?.userId == next?.userId && 
           prev?.isLogined == next?.isLogined;
  });
});

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
  //ref.read(wordStatusSyncServiceProvider).dispose();
  ref.read(espJpnWordStatusSyncServiceProvider).dispose();
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
    //await _startSyncService(ref, currentAuth.userId);
  await ref.read(espJpnWordStatusSyncServiceProvider)
        .syncOnce(currentAuth.userId)
        .then((_) {
          print('[Auth Effect] Initial sync completed');
        })
        .catchError((error) {
          print('[Auth Effect] Initial sync failed: $error');
        });
        
    ref.read(espJpnWordStatusSyncServiceProvider)
        .startSyncWithRemote(currentAuth.userId);

            // 5. バックグラウンドで一回限りの同期を実行
    // ユーザー操作をブロックしないようにawaitしない

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


//
/// 同期サービスの開始
// Future<void> _startSyncService(Ref ref, String userId) async {
//   final syncDao = ref.read(sharedPreferenceSyncStatusDaoProvider);
//   final lastSync = await syncDao.getLastSyncDate();

//   final startPoint =
//       lastSync ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

//   ref.read(wordStatusSyncServiceProvider).startSync(
//     userId,
//     startPoint,
//     (newLastSync) async {
//       await syncDao.updateLastSyncDate(newLastSync);
//       ref.read(setLastSyncProvider)(newLastSync);
//     },
//   );

//   print('[Auth Effect] Sync service started from: $startPoint');
// }

