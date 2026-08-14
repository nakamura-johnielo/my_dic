import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/auth_composition.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/auth/port/auth.dart';
import 'auth_lifecycle_provider.dart';

final authStreamProvider = StreamProvider<AuthIdentity?>((ref) {
  final query = ref.watch(authQueryPortProvider);
  return query.observeAuthState().distinct((previous, next) =>
      previous?.accountId == next?.accountId &&
      previous?.emailVerified == next?.emailVerified);
});

/// Connects the Auth producer to the app-owned lifecycle controller once.
final authLifecycleEffectProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AuthIdentity?>>(authStreamProvider,
      (previous, next) async {
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
