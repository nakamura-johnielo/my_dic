import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/features/sync/application/in_memory_session_fence.dart';

/// Advances the sync session epoch whenever the signed-in account changes,
/// and marks it current in [InMemorySessionFence].
///
/// This does not start or cancel any in-flight sync cycle by itself: no
/// production `SyncEngine` trigger is wired yet (see Local-first 5-7). It
/// keeps the fence ready so that once a cycle is started with a `SyncContext`
/// carrying this `accountId`/`sessionEpoch`, an account switch mid-cycle is
/// already rejected by `SessionFence.isCurrent`.
final sessionFenceEffectProvider = Provider<void>((ref) {
  final fence = ref.watch(syncSessionFenceProvider);
  final tracker = _SessionEpochTracker(fence);
  ref.listen<AppSession>(
    appSessionProvider,
    tracker.onSessionChanged,
    fireImmediately: true,
  );
});

class _SessionEpochTracker {
  _SessionEpochTracker(this._fence);

  final InMemorySessionFence _fence;
  String? _accountId;
  int _epoch = 0;

  void onSessionChanged(AppSession? previous, AppSession next) {
    final nextAccountId = next.accountIdOrNull;
    if (nextAccountId == _accountId) return;

    if (_accountId != null) {
      _fence.remove(_accountId!);
    }
    _accountId = nextAccountId;
    if (nextAccountId != null) {
      _epoch++;
      _fence.setCurrent(nextAccountId, _epoch);
    }
  }
}
