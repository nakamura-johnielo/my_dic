import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/sync/port/sync.dart';
import 'session_fence_service.dart';
import 'auth_lifecycle_state.dart';

/// セッションエポックを発行する唯一のコンポーネント。
///
/// UIの [AppSession] 投影ではなく、生のライフサイクル状態を受け取ります。この区別により、
/// 一時的にサインアウトのように見えるUI状態がゲスト所有データを有効化することを防ぎます。
final class SessionEpochCoordinator {
  SessionEpochCoordinator(this._fence, this._scheduler);

  final SessionFenceService _fence;
  final SyncRunner _scheduler;
  int _nextEpoch = 0;
  SessionScopeKey? _active;
  bool _disposed = false;

  SessionScopeKey? get activeScope => _active;

  /// ライフサイクルイベントを適用し、安定している場合はアクティブなスコープを返します。
  /// 中間状態では直前のスコープを同期的に切り離し、置き換えクエリは開始しません。
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

  /// このコンポジションルートが所有するスコープを解放します。
  ///
  /// フェンスはプロバイダーコンテナーより長く存在してはいけません。そのため、破棄された
  /// アプリケーションツリーからすでに予定されていた同期は拒否されます。
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _detach();
  }
}
