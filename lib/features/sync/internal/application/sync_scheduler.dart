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

/// ライフサイクルアダプターだけがこのクラスを呼び出します。意図的に Firebase、Drift、
/// リスナー、機能固有の動作を含みません。
class SyncScheduler {
  SyncScheduler(this._engine,
      {SyncTelemetry telemetry = const NoopSyncTelemetry(),
      SyncQueue? queue,
      SyncRetryWakeup? retryWakeup,
      SessionFence? sessionFence,
      DateTime Function()? clock})
      : assert((queue == null) == (retryWakeup == null)),
        _telemetry = telemetry,
        _queue = queue,
        _retryWakeup = retryWakeup,
        _sessionFence = sessionFence,
        _clock = clock ?? DateTime.now;
  final SyncEngine _engine;
  final SyncTelemetry _telemetry;
  final SyncQueue? _queue;
  final SyncRetryWakeup? _retryWakeup;
  final SessionFence? _sessionFence;
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
      // 可観測性は厳密にベストエフォートであり、同期出力を変更してはなりません。
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
      // 再試行の起床はベストエフォートです。永続キューは変更されません。
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

  /// セッション変更時に、以前のアカウントの起床をキャンセルします。
  void cancelRetryForAccount(String accountId) =>
      _retryWakeup?.cancel(accountId);

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _retryWakeup?.dispose();
  }
}
