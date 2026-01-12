import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/coordinator/corrdinator.dart';
import 'package:my_dic/features/esp_jpn_word_status/di/di.dart';
import 'package:my_dic/features/my_word/di/service_di.dart';
import 'package:my_dic/features/auth/di/view_model_di.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';

/// 認証状態のストリームプロバイダー
/// Authを常に監視
final authStreamProvider = StreamProvider<AppAuth?>((ref) {
  final authCoordinator = ref.read(authCoordinatorProvider);
  return authCoordinator.observeAuthState().distinct((prev, next) {
    // accountId と isLogined が両方同じなら重複とみなす
    // print(
    //     "*****distinct check prev: ${prev?.accountId}, isLogined: ${prev?.isLogined}, isAuthenticated: ${prev?.isAuthenticated} *****");
    // print(
    //     "*****distinct check next: ${next?.accountId}, isLogined: ${next?.isLogined}, isAuthenticated: ${next?.isAuthenticated} *****");
    return 
    prev?.accountId == next?.accountId &&
           prev?.isLogined == next?.isLogined &&
           prev?.isAuthenticated == next?.isAuthenticated;
  });
});

/// 認証状態の変化を監視し、副作用を実行
final authEffectProvider = Provider<void>((ref) {
  // Keep sync services alive while this effect provider is alive.
  ref.watch(espJpnWordStatusSyncServiceProvider);
  ref.watch(myWordSyncServiceProvider);

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

  final authUserCoordinator=ref.read(authUserCoordinatorProvider);
  await  authUserCoordinator.signOut();
  // ViewModelの状態をクリア
  // if (previousAuth != null) {
  //   ref.read(userViewModelProviderLegacy.notifier).setAuthInfo(
  //         AppAuth(accountId: 'logout', isLogined: false),
  //       );
  // }

  // 同期サービスを停止
  //ref.read(espJpnWordStatusSyncServiceProvider).dispose();
}

/// サインイン時の処理
Future<void> _handleSignIn(Ref ref, AppAuth currentAuth) async {
  print('[Auth Effect] User signed in: ${currentAuth.accountId}');

  try {
    
  final authUserCoordinator=ref.read(authUserCoordinatorProvider);
  await  authUserCoordinator.updateAuth(currentAuth);
    // 2. ユーザー情報をロード
    // await ref.read(userViewModelProviderLegacy.notifier).loadUser(currentAuth.accountId);

    // 3. 認証情報を同期
    //ref.read(userViewModelProvider.notifier).setAuthInfo(currentAuth);

    // 4. 同期サービスを開始
    //await _startSyncService(ref, currentAuth.accountId);
    if(!currentAuth.isLogined || !currentAuth.isAuthenticated){
      print('[Auth Effect] User not verified, skipping sync service start');
      return;
    }
    
    final syncResult = await ref
        .read(espJpnWordStatusSyncServiceProvider)
        .syncOnce(currentAuth.accountId);

    await ref
      .read(myWordSyncServiceProvider)
      .syncOnce(currentAuth.accountId);
    
    // Note: syncOnce already logs the result internally via .when()
    // No need for additional .then() or .catchError()

    // ref
    //     .read(espJpnWordStatusSyncServiceProvider)
    //     .startSyncWithRemote(currentAuth.accountId);

    // 5. バックグラウンドで一回限りの同期を実行
    // ユーザー操作をブロックしないようにawaitしない
  } catch (e) {
    print('[Auth Effect] Error during sign in: $e');
    // エラーハンドリング（必要に応じてUIにエラーを通知）
  }
}

/// 新規ユーザー登録時の処理
// Future<void> _handleNewUserSignUp(Ref ref, AppAuth auth) async {
//   print('[Auth Effect] Creating new user profile: ${auth.accountId}');

//   final newUser = AppUser(
//     id: auth.accountId,
//     email: auth.email,
//     username: auth.email?.split('@')[0] ?? 'User',
//     subscriptionStatus: SubscriptionStatus.trial,
//   );

//   try {
//     // ユーザープロファイル作成
//     await ref.read(userViewModelProvider.notifier).updateUser(newUser);

//     // メール認証送信
//     if (!auth.isAuthenticated) {
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
// Future<void> _startSyncService(Ref ref, String accountId) async {
//   final syncDao = ref.read(sharedPreferenceSyncStatusDaoProvider);
//   final lastSync = await syncDao.getLastSyncDate();

//   final startPoint =
//       lastSync ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

//   ref.read(wordStatusSyncServiceProvider).startSync(
//     accountId,
//     startPoint,
//     (newLastSync) async {
//       await syncDao.updateLastSyncDate(newLastSync);
//       ref.read(setLastSyncProvider)(newLastSync);
//     },
//   );

//   print('[Auth Effect] Sync service started from: $startPoint');
// }

