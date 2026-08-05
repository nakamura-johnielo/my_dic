import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/auth/di/view_model_di.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/features/sync/di.dart';
import 'package:my_dic/features/user/di/viewmodel.dart';

/// 認証状態のストリームプロバイダー
/// Authを常に監視
final authStreamProvider = StreamProvider<AppAuth?>((ref) {
  final authCoordinator = ref.read(authCoordinatorProvider);
  return authCoordinator.observeAuthState().distinct((prev, next) {
    // accountId と isLogined が両方同じなら重複とみなす
    return prev?.accountId == next?.accountId &&
        prev?.isLogined == next?.isLogined &&
        prev?.isAuthenticated == next?.isAuthenticated;
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
  if (previousAuth?.accountId == currentAuth?.accountId &&
      previousAuth?.isLogined == currentAuth?.isLogined &&
      previousAuth?.isAuthenticated == currentAuth?.isAuthenticated) {
    AppLogger.event('auth.state.unchanged');
    return;
  }

  // ログアウト後の処理
  if (currentAuth == null) {
    AppLogger.event('auth.sign_out.detected');
    await _handleSignOut(ref, previousAuth);
    return;
  }

  // ログイン後の処理
  AppLogger.event('auth.sign_in.detected');
  await _handleSignIn(ref, currentAuth);
}

/// サインアウト時の処理
Future<void> _handleSignOut(Ref ref, AppAuth? previousAuth) async {
  AppLogger.event('auth.sign_out.handling');

  final authCoordinator = ref.read(authCoordinatorProvider);
  authCoordinator.setAuth(AppAuth(accountId: ""));

  final userCoordinator = ref.read(appUserCoordinatorProvider);
  userCoordinator.clear();
}

/// サインイン時の処理
Future<void> _handleSignIn(Ref ref, AppAuth currentAuth) async {
  AppLogger.event('auth.sign_in.handling');

  try {
    final authCoordinator = ref.read(authCoordinatorProvider);
    authCoordinator.setAuth(currentAuth);

    final userCoordinator = ref.read(appUserCoordinatorProvider);
    userCoordinator.refresh();

    if (!currentAuth.isLogined || !currentAuth.isAuthenticated) {
      AppLogger.event('auth.sign_in.sync_skipped_unverified');
      return;
    }
    await ref.read(syncServiceProvider).syncOnceAll();
  } catch (error) {
    AppLogger.event(
      'auth.sign_in.effect_failed',
      context: {'errorType': error.runtimeType.toString()},
    );
    // エラーハンドリング（必要に応じてUIにエラーを通知）
  }
}
