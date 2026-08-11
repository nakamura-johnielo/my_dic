import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/app/bootstrap/session_composition.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/auth_lifecycle_effects.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/sync/port/cancellation_token.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';

/// Owns application-wide effects independently from widget rebuilds.
///
/// Drives Sync via the public `syncRunnerProvider` workflow entry point
/// whenever the session becomes ready and whenever the app is resumed.
final applicationLifecycleEffectsProvider = Provider<void>((ref) {
  SessionScopeKey? lastSessionReadyScope;
  final observer = _ApplicationLifecycleObserver(
    onResumed: () => _triggerForegroundSync(
      ref,
      reason: 'app_resumed',
    ),
  );
  WidgetsBinding.instance.addObserver(observer);
  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(observer);
  });

  ref.watch(authLifecycleEffectProvider);
  ref.watch(sessionFenceEffectProvider);
  ref.read(syncRunnerProvider);

  ref.listen<AppSession>(appSessionProvider, (previous, next) {
    if (next is! AppSessionReady) return;
    final scope = ref.read(sessionScopeKeyProvider);
    // A ready profile may publish repeatedly. One stable scope activation
    // (login, logout→guest→login, or account switch) gets exactly one
    // foreground trigger; app-resume remains an intentionally separate event.
    if (scope == null || scope == lastSessionReadyScope) return;
    lastSessionReadyScope = scope;
    _triggerForegroundSync(ref, reason: 'session_ready');
  }, fireImmediately: true);
});

Future<void> _triggerForegroundSync(Ref ref, {required String reason}) async {
  final scope = ref.read(sessionScopeKeyProvider);
  if (scope == null) return;
  try {
    await ref.read(syncRunnerProvider).foreground(SyncContext(
          accountId: scope.accountScope,
          sessionEpoch: scope.epoch,
          reason: reason,
          cancellation: CancellationToken(),
        ));
  } catch (_) {
    // Sync outcomes are reported by the scheduler; never expose an unexpected
    // exception's free-form text in an application log.
    AppLogger.print('Foreground sync did not complete.');
  }
}

class _ApplicationLifecycleObserver with WidgetsBindingObserver {
  _ApplicationLifecycleObserver({required this.onResumed});
  final void Function() onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResumed();
  }
}
