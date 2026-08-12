import 'package:my_dic/features/sync/port/cancellation_token.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/model/sync_report.dart';
import 'package:my_dic/features/sync/port/session_fence.dart';
import 'package:my_dic/features/sync/port/sync_queue.dart';
import 'package:my_dic/features/sync/port/sync_retry_wakeup.dart';
import 'package:my_dic/features/sync/port/sync_telemetry.dart';
import 'package:my_dic/features/sync/port/sync_reason_codes.dart';
import 'report/sync_report_summary.dart';
import 'sync_engine.dart';

/// Lifecycle adapters invoke this class only. It deliberately contains no
/// Firebase, Drift, listener, or feature-specific behaviour.
class SyncScheduler {
  SyncScheduler(this._engine,
      {ISyncTelemetry telemetry = const NoopSyncTelemetry(),
      ISyncQueue? queue,
      ISyncRetryWakeup? retryWakeup,
      ISessionFence? sessionFence,
      DateTime Function()? clock})
      : assert((queue == null) == (retryWakeup == null)),
        _telemetry = telemetry,
        _queue = queue,
        _retryWakeup = retryWakeup,
        _sessionFence = sessionFence,
        _clock = clock ?? DateTime.now;
  final SyncEngine _engine;
  final ISyncTelemetry _telemetry;
  final ISyncQueue? _queue;
  final ISyncRetryWakeup? _retryWakeup;
  final ISessionFence? _sessionFence;
  final DateTime Function() _clock;
  bool _disposed = false;

  Future<SyncReport> foreground(SyncContext context) async {
    final report = await _engine.runOnce(context);
    try {
      await _telemetry.recordCycleCompleted(
        trigger: context.reason,
        report: report,
      );
    } catch (_) {
      // Observability is strictly best-effort and must not change sync output.
    }
    await _armRetryIfNeeded(context, report);
    return report;
  }

  Future<void> _armRetryIfNeeded(SyncContext context, SyncReport report) async {
    if (_disposed ||
        _queue == null ||
        _retryWakeup == null ||
        !SyncReportSummary.fromReport(report).hasRetryableFailure) {
      return;
    }
    try {
      final dueAt = await _queue.earliestPendingAttemptAt(
        accountId: context.accountId,
      );
      if (dueAt == null) return;
      _retryWakeup.arm(
        accountId: context.accountId,
        dueAt: dueAt,
        onDue: () => _onRetryDue(context, dueAt.toUtc()),
      );
    } catch (_) {
      // Retry wake-up is best-effort. The durable queue remains unchanged.
    }
  }

  void _onRetryDue(SyncContext source, DateTime dueAt) {
    if (_disposed ||
        (_sessionFence != null &&
            !_sessionFence.isCurrent(
              accountId: source.accountId,
              sessionEpoch: source.sessionEpoch,
            ))) {
      return;
    }
    if (_clock().toUtc().isBefore(dueAt)) {
      _retryWakeup?.arm(
        accountId: source.accountId,
        dueAt: dueAt,
        onDue: () => _onRetryDue(source, dueAt),
      );
      return;
    }
    foreground(SyncContext(
      accountId: source.accountId,
      sessionEpoch: source.sessionEpoch,
      reason: SyncReasonCodes.retryDue,
      cancellation: CancellationToken(),
    ));
  }

  /// Cancels a prior account's wake-up when its session changes.
  void cancelRetryForAccount(String accountId) =>
      _retryWakeup?.cancel(accountId);

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _retryWakeup?.dispose();
  }
}
