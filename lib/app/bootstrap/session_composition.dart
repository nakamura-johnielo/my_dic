import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/app/workflows/session_lifecycle/session_epoch_coordinator.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/session/session_scope_provider.dart';
import 'package:my_dic/app/workflows/session_lifecycle/auth_lifecycle_provider.dart';

export 'package:my_dic/core/session/session_scope_provider.dart'
    show sessionScopeKeyProvider;

/// One container owns exactly one coordinator and thus one epoch counter.
final sessionEpochCoordinatorProvider =
    Provider<SessionEpochCoordinator>((ref) {
  final coordinator = SessionEpochCoordinator(
    ref.watch(syncSessionFenceProvider),
    ref.watch(syncRunnerProvider),
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

/// The active presentation/query identity. `null` means an intermediate
/// lifecycle phase, and callers must detach rather than treat it as guest.
SessionScopeKey? resolveSessionScopeKey(Ref ref) {
  final lifecycle = ref.watch(authLifecycleProvider);
  return ref
      .watch(sessionEpochCoordinatorProvider)
      .onLifecycleChanged(lifecycle);
}

/// Installs the single session coordinator listener. The coordinator itself is
/// owned by [sessionEpochCoordinatorProvider], so all consumers observe the
/// same epoch sequence.
final sessionFenceEffectProvider = Provider<void>((ref) {
  ref.watch(sessionScopeKeyProvider);
});
