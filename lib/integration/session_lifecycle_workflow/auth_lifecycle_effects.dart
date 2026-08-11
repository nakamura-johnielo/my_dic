import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/auth/port/app_auth.dart';
import 'auth_lifecycle_provider.dart';

final authStreamProvider = StreamProvider<AppAuth?>((ref) {
  final observer = ref.watch(authLifecyclePortsProvider).observeAuthState;
  return observer.observeAuthState().distinct((previous, next) =>
      previous?.accountId == next?.accountId &&
      previous?.isLogined == next?.isLogined &&
      previous?.isAuthenticated == next?.isAuthenticated);
});

/// Connects the Auth producer to the app-owned lifecycle controller once.
final authLifecycleEffectProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AppAuth?>>(authStreamProvider, (previous, next) async {
    await next.when(
      data: (auth) async {
        try {
          await ref
              .read(authLifecycleProvider.notifier)
              .handleAuthStateChange(auth);
        } catch (error, stackTrace) {
          AppLogger.event('auth.lifecycle.effect_failed',
              context: {'errorType': error.runtimeType.toString()});
          ref
              .read(authLifecycleProvider.notifier)
              .reportUnexpected(error, stackTrace);
        }
      },
      loading: () async {},
      error: (error, stackTrace) async {
        AppLogger.event('auth.stream.failed',
            context: {'errorType': error.runtimeType.toString()});
        ref
            .read(authLifecycleProvider.notifier)
            .reportUnexpected(error, stackTrace);
      },
    );
  });
});
