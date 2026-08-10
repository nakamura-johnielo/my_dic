import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/sync/port/sync_runner.dart';
import 'session_fence_adapter.dart';
import 'auth_lifecycle_state.dart';

/// The sole issuer of session epochs.
///
/// It accepts raw lifecycle states rather than the UI [AppSession] projection:
/// that distinction is what prevents transient signed-out-looking UI states
/// from activating guest-owned data.
final class SessionEpochCoordinator {
  SessionEpochCoordinator(this._fence, this._scheduler);

  final SessionFenceAdapter _fence;
  final SyncRunner _scheduler;
  int _nextEpoch = 0;
  SessionScopeKey? _active;
  bool _disposed = false;

  SessionScopeKey? get activeScope => _active;

  /// Applies a lifecycle event and returns the active scope, if it is stable.
  /// Intermediate states synchronously detach the previous scope and never
  /// start a replacement query.
  SessionScopeKey? onLifecycleChanged(AuthLifecycleState lifecycle) {
    if (_disposed) return null;
    final accountScope = switch (lifecycle.phase) {
      AuthLifecyclePhase.ready when lifecycle.auth != null =>
        lifecycle.auth!.accountId,
      AuthLifecyclePhase.signedOut => guestAccountScope,
      _ => null,
    };

    if (accountScope == null) {
      _detach();
      return null;
    }

    final current = _active;
    if (current != null && current.accountScope == accountScope) {
      return current;
    }

    _detach();
    final next = SessionScopeKey(
      accountScope: accountScope,
      epoch: ++_nextEpoch,
    );
    _active = next;
    _fence.activate(next.accountScope, next.epoch);
    return next;
  }

  void _detach() {
    final previous = _active;
    if (previous == null) return;
    _scheduler.cancelRetryForAccount(previous.accountScope);
    _fence.deactivate(previous.accountScope);
    _active = null;
  }

  /// Releases the scope owned by this composition root.
  ///
  /// A fence must never outlive its provider container: an already scheduled
  /// sync from a disposed application tree is consequently rejected.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _detach();
  }
}
