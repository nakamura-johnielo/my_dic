import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/guest_migration_composition.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/app/guest_migration/presentation/guest_data_migration_dialog.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/sync/application/cancellation_token.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/router/router.dart';

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
        _maybePrompt(next.identity.accountId);
      }
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  Future<void> _maybePrompt(String accountId) async {
    if (_checking) return;
    _checking = true;
    try {
      final summary = await ref.read(detectGuestDataUseCaseProvider).execute();
      if (!mounted || summary.isEmpty) return;

      final navigatorContext =
          ref.read(rootNavigatorKeyProvider).currentContext;
      if (navigatorContext == null || !navigatorContext.mounted) return;

      final approved = await showDialog<bool>(
        context: navigatorContext,
        barrierDismissible: false,
        builder: (_) => GuestDataMigrationDialog(summary: summary),
      );

      if (approved == true) {
        await ref.read(migrateGuestDataUseCaseProvider).execute(accountId);
        await _triggerForegroundSyncAfterMigration(accountId);
      }
    } catch (error) {
      AppLogger.print('Guest data migration prompt failed: $error');
    } finally {
      _checking = false;
    }
  }

  Future<void> _triggerForegroundSyncAfterMigration(String accountId) async {
    final epoch = ref.read(syncSessionFenceProvider).epochFor(accountId);
    if (epoch == null) return;
    try {
      await ref.read(syncSchedulerProvider).foreground(SyncContext(
            accountId: accountId,
            sessionEpoch: epoch,
            reason: 'guest_migration',
            cancellation: CancellationToken(),
          ));
    } catch (error) {
      AppLogger.print('Post-migration foreground sync failed: $error');
    }
  }
}
