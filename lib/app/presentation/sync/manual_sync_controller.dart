import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/feature_composition/sync_composition.dart';
import 'package:my_dic/app/bootstrap/session_composition.dart';
import 'package:my_dic/app/presentation/sync/manual_sync_ui_state.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/sync/port/sync.dart';

final manualSyncControllerProvider =
    StateNotifierProvider<ManualSyncController, ManualSyncUiState>((ref) {
  final controller = ManualSyncController(
    scheduler: ref.read(syncRunnerProvider),
    sessionFence: ref.read(syncSessionFenceProvider),
    currentScope: () => ref.read(sessionScopeKeyProvider),
    initialSession: ref.read(appSessionProvider),
  );
  ref.listen<AppSession>(appSessionProvider, (_, next) {
    controller.onSessionChanged(next);
  });
  return controller;
});

/// Coordinates a user-requested foreground sync without making sync internals
/// part of presentation state.
class ManualSyncController extends StateNotifier<ManualSyncUiState>
    implements UiEffectConsumer {
  ManualSyncController({
    required SyncRunner scheduler,
    required SessionFence sessionFence,
    required SessionScopeKey? Function() currentScope,
    required AppSession initialSession,
  })  : _scheduler = scheduler,
        _sessionFence = sessionFence,
        _currentScope = currentScope,
        _readyAccountId = initialSession.accountIdOrNull,
        super(const ManualSyncUiState());

  final SyncRunner _scheduler;
  final SessionFence _sessionFence;
  final SessionScopeKey? Function() _currentScope;
  String? _readyAccountId;
  CancellationToken? _cancellation;
  int _generation = 0;
  int _effectSequence = 0;

  @override
  UiEffectEnvelope<UiEffect>? get pendingEffect => state.pendingEffect;

  @override
  void consumeEffect(String id) {
    if (shouldConsumeEffect(pendingEffect: state.pendingEffect, id: id)) {
      state = state.copyWith(clearEffect: true);
    }
  }

  /// Cancels an in-flight request and discards its notice when the usable
  /// account changes (or ceases to be ready).
  void onSessionChanged(AppSession session) {
    final nextAccountId = session.accountIdOrNull;
    if (nextAccountId == _readyAccountId) return;
    _readyAccountId = nextAccountId;
    _generation++;
    _cancellation?.cancel(SyncReasonCodes.sessionChanged);
    _cancellation = null;
    if (!mounted) return;
    state = const ManualSyncUiState();
  }

  Future<void> sync(AppSession session) async {
    if (state.isSyncing || session is! AppSessionReady) return;

    final accountId = session.accountIdOrNull;
    if (accountId == null || accountId != _readyAccountId) return;
    final scope = _currentScope();
    if (scope == null || scope.accountScope != accountId) return;
    final epoch = scope.epoch;

    final generation = _generation;
    final cancellation = CancellationToken();
    _cancellation = cancellation;
    state = const ManualSyncUiState(isSyncing: true);
    try {
      final outcome = await _scheduler.foreground(SyncContext(
        accountId: accountId,
        sessionEpoch: epoch,
        reason: SyncReasonCodes.manual,
        cancellation: cancellation,
      ));
      if (!_isCurrentRequest(accountId, epoch, generation)) return;

      if (outcome != SyncRunOutcome.cancelled) {
        state = ManualSyncUiState(
          pendingEffect: _notice(_messageFor(outcome)),
        );
      } else {
        state = const ManualSyncUiState();
      }
    } catch (_) {
      if (!_isCurrentRequest(accountId, epoch, generation) ||
          cancellation.isCancelled) {
        return;
      }
      state = ManualSyncUiState(
        pendingEffect:
            _notice('Sync could not be completed. Please try again.'),
      );
    } finally {
      if (_isCurrentRequest(accountId, epoch, generation)) {
        _cancellation = null;
        if (state.isSyncing) state = state.copyWith(isSyncing: false);
      }
    }
  }

  bool _isCurrentRequest(String accountId, int epoch, int generation) =>
      mounted &&
      generation == _generation &&
      _readyAccountId == accountId &&
      _sessionFence.isCurrent(accountId: accountId, sessionEpoch: epoch);

  UiEffectEnvelope<UiEffect> _notice(String message) => UiEffectEnvelope(
        id: 'manual-sync-${++_effectSequence}',
        effect: UiNoticeEffect(message),
      );

  String _messageFor(SyncRunOutcome outcome) => switch (outcome) {
        SyncRunOutcome.retryScheduled => 'Sync will retry automatically.',
        SyncRunOutcome.nonRetryableFailure => 'Sync needs attention.',
        SyncRunOutcome.success => 'Sync complete.',
        SyncRunOutcome.cancelled => '',
      };

  @override
  void dispose() {
    _generation++;
    _cancellation?.cancel(SyncReasonCodes.callerCancelled);
    _cancellation = null;
    super.dispose();
  }
}
