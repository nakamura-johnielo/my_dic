import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/app/presentation/sync/manual_sync_ui_state.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/features/sync/application/cancellation_token.dart';
import 'package:my_dic/features/sync/application/in_memory_session_fence.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/report/sync_reason_codes.dart';
import 'package:my_dic/features/sync/application/report/sync_report_interpreter.dart';
import 'package:my_dic/features/sync/application/report/sync_report_summary.dart';
import 'package:my_dic/features/sync/application/sync_scheduler.dart';

final manualSyncControllerProvider =
    StateNotifierProvider<ManualSyncController, ManualSyncUiState>((ref) {
  final controller = ManualSyncController(
    scheduler: ref.read(syncSchedulerProvider),
    sessionFence: ref.read(syncSessionFenceProvider),
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
    required SyncScheduler scheduler,
    required InMemorySessionFence sessionFence,
    required AppSession initialSession,
    SyncReportInterpreter interpreter = const SyncReportInterpreter(),
  })  : _scheduler = scheduler,
        _sessionFence = sessionFence,
        _interpreter = interpreter,
        _readyAccountId = initialSession.accountIdOrNull,
        super(const ManualSyncUiState());

  final SyncScheduler _scheduler;
  final InMemorySessionFence _sessionFence;
  final SyncReportInterpreter _interpreter;
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
    final epoch = _sessionFence.epochFor(accountId);
    if (epoch == null) return;

    final generation = _generation;
    final cancellation = CancellationToken();
    _cancellation = cancellation;
    state = const ManualSyncUiState(isSyncing: true);
    try {
      final report = await _scheduler.foreground(SyncContext(
        accountId: accountId,
        sessionEpoch: epoch,
        reason: SyncReasonCodes.manual,
        cancellation: cancellation,
      ));
      if (!_isCurrentRequest(accountId, epoch, generation)) return;

      final summary = SyncReportSummary.fromReport(report);
      final outcome = _interpreter.interpret(report);
      if (outcome != SyncReportOutcome.cancelled) {
        state = ManualSyncUiState(
          pendingEffect: _notice(_messageFor(outcome, summary)),
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

  String _messageFor(SyncReportOutcome outcome, SyncReportSummary summary) =>
      switch (outcome) {
        SyncReportOutcome.alreadyRunning => 'Sync is already running.',
        SyncReportOutcome.authenticationRequired =>
          'Please sign in again before syncing.',
        SyncReportOutcome.needsAttention => 'Sync needs attention.',
        SyncReportOutcome.offlineDeferred =>
          'You are offline. Sync will retry when possible.',
        SyncReportOutcome.retryScheduled => 'Sync will retry automatically.',
        SyncReportOutcome.partialSuccess => 'Sync completed with warnings.',
        SyncReportOutcome.succeeded =>
          summary.pushedCount + summary.pulledCount > 0
              ? 'Sync complete.'
              : 'Everything is up to date.',
        SyncReportOutcome.cancelled => '',
      };

  @override
  void dispose() {
    _generation++;
    _cancellation?.cancel(SyncReasonCodes.callerCancelled);
    _cancellation = null;
    super.dispose();
  }
}
