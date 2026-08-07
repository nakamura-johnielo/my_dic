import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/application/effects/auth_effect_provider.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/app/bootstrap/session_composition.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/features/sync/application/cancellation_token.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/report/sync_reason_codes.dart';

/// Owns application-wide effects independently from widget rebuilds.
///
/// Drives the new `SyncEngine` via `syncSchedulerProvider.foreground(...)`
/// whenever the session becomes ready and whenever the app is resumed.
final applicationLifecycleEffectsProvider = Provider<void>((ref) {
  final observer = _ApplicationLifecycleObserver(
    onResumed: () => _triggerForegroundSync(
      ref,
      reason: SyncReasonCodes.appResumed,
    ),
  );
  WidgetsBinding.instance.addObserver(observer);
  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(observer);
  });

  ref.watch(authEffectProvider);
  ref.watch(sessionFenceEffectProvider);
  ref.read(syncSchedulerProvider);

  ref.listen<AppSession>(appSessionProvider, (previous, next) {
    if (next is AppSessionReady) {
      _triggerForegroundSync(ref, reason: SyncReasonCodes.sessionReady);
    }
  }, fireImmediately: true);
});

Future<void> _triggerForegroundSync(Ref ref, {required String reason}) async {
  final accountId = ref.read(currentSessionProvider).accountIdOrNull;
  if (accountId == null) return;
  final epoch = ref.read(syncSessionFenceProvider).epochFor(accountId);
  if (epoch == null) return;
  try {
    await ref.read(syncSchedulerProvider).foreground(SyncContext(
          accountId: accountId,
          sessionEpoch: epoch,
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
