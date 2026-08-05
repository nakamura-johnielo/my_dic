import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_provider.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/auth/di/usecase_di.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';

/// 認証状態のストリームプロバイダー
/// Authを常に監視
final authStreamProvider = StreamProvider<AppAuth?>((ref) {
  final observeAuthState = ref.watch(observeAuthStateUseCaseProvider);
  return observeAuthState.execute().distinct((prev, next) {
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
      await next.when(
        data: (auth) async {
          try {
            await ref
                .read(authLifecycleProvider.notifier)
                .handleAuthStateChange(auth);
          } catch (error, stackTrace) {
            AppLogger.event(
              'auth.lifecycle.effect_failed',
              context: {'errorType': error.runtimeType.toString()},
            );
            ref
                .read(authLifecycleProvider.notifier)
                .reportUnexpected(error, stackTrace);
          }
        },
        loading: () async {},
        error: (error, stackTrace) async {
          AppLogger.event(
            'auth.stream.failed',
            context: {'errorType': error.runtimeType.toString()},
          );
          ref
              .read(authLifecycleProvider.notifier)
              .reportUnexpected(error, stackTrace);
        },
      );
    },
  );
});
