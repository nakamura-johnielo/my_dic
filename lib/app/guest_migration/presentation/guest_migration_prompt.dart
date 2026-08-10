import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/guest_migration_composition.dart';
import 'package:my_dic/app/bootstrap/session_composition.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/app/guest_migration/presentation/guest_data_migration_dialog.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/sync/port/cancellation_token.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/app/routing/router.dart';

/// Invisible widget that watches for a newly-ready session and, if any
/// guest-scoped local data is found, asks the user whether to migrate it
/// into the account. Placed once near the app root (see `app.dart`).
class GuestMigrationPrompt extends ConsumerStatefulWidget {
  const GuestMigrationPrompt({super.key});

  @override
  ConsumerState<GuestMigrationPrompt> createState() =>
      _GuestMigrationPromptState();
}

class _GuestMigrationPromptState extends ConsumerState<GuestMigrationPrompt> {
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // `listenManual` is the ConsumerState API intended for initState and
    // supports the initial ready session as well as later sign-ins.
    ref.listenManual<AppSession>(appSessionProvider, (previous, next) {
      if (next is AppSessionReady) {
        final scope = ref.read(sessionScopeKeyProvider);
        if (scope != null && scope.accountScope == next.identity.accountId) {
          _maybePrompt(scope.accountScope, scope.epoch);
        }
      }
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  Future<void> _maybePrompt(String accountId, int sessionEpoch) async {
    if (_checking) return;
    _checking = true;
    try {
      final fence = ref.read(syncSessionFenceProvider);
      final summary = await ref.read(detectGuestDataUseCaseProvider).execute();
      if (!mounted ||
          summary.isEmpty ||
          !fence.isCurrent(
            accountId: accountId,
            sessionEpoch: sessionEpoch,
          )) {
        return;
      }

      final navigatorContext =
          ref.read(rootNavigatorKeyProvider).currentContext;
      if (navigatorContext == null || !navigatorContext.mounted) return;

      final approved = await showDialog<bool>(
        context: navigatorContext,
        barrierDismissible: false,
        builder: (_) => GuestDataMigrationDialog(summary: summary),
      );

      if (approved == true &&
          fence.isCurrent(
            accountId: accountId,
            sessionEpoch: sessionEpoch,
          )) {
        await ref
            .read(migrateGuestDataUseCaseProvider)
            .execute(accountId, sessionEpoch);
        await _triggerForegroundSyncAfterMigration(accountId, sessionEpoch);
      }
    } catch (_) {
      AppLogger.print('Guest data migration prompt did not complete.');
    } finally {
      _checking = false;
    }
  }

  Future<void> _triggerForegroundSyncAfterMigration(
      String accountId, int epoch) async {
    try {
      await ref.read(syncRunnerProvider).foreground(SyncContext(
            accountId: accountId,
            sessionEpoch: epoch,
            reason: 'post_guest_migration',
            cancellation: CancellationToken(),
          ));
    } catch (_) {
      // The scheduler records completed reports itself. Keep unexpected
      // exceptions out of logs because their text may carry remote details.
      AppLogger.print('Post-migration foreground sync did not complete.');
    }
  }
}
