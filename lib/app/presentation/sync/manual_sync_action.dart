import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/presentation/sync/manual_sync_controller.dart';
import 'package:my_dic/app/presentation/sync/manual_sync_ui_state.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';

/// The ready-session app-bar entry point for a user-requested sync.
class ManualSyncAction extends ConsumerStatefulWidget {
  const ManualSyncAction({super.key});

  @override
  ConsumerState<ManualSyncAction> createState() => _ManualSyncActionState();
}

class _ManualSyncActionState extends ConsumerState<ManualSyncAction> {
  late final ProviderSubscription<ManualSyncUiState> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = ref.listenManual(
      manualSyncControllerProvider,
      (_, next) => _handleEffect(next),
    );
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }

  void _handleEffect(ManualSyncUiState next) {
    final envelope = next.pendingEffect;
    if (envelope == null) return;
    if (mounted && envelope.effect is UiNoticeEffect) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((envelope.effect as UiNoticeEffect).message)),
      );
    }
    ref.read(manualSyncControllerProvider.notifier).consumeEffect(envelope.id);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final sync = ref.watch(manualSyncControllerProvider);
    if (session is! AppSessionReady) return const SizedBox.shrink();

    return IconButton(
      tooltip: 'Sync now',
      onPressed: sync.isSyncing
          ? null
          : () => ref.read(manualSyncControllerProvider.notifier).sync(session),
      icon: sync.isSyncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.sync),
    );
  }
}
