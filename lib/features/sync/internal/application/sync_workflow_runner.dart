import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/sync_run_outcome.dart';
import 'package:my_dic/features/sync/port/sync_runner.dart';
import 'report/sync_report_interpreter.dart';
import 'sync_scheduler.dart';

/// 内部レポートの詳細を公開ワークフロー結果へ集約します。
final class SyncWorkflowRunner implements SyncRunner {
  SyncWorkflowRunner(this._scheduler, {SyncReportInterpreter? interpreter})
      : _interpreter = interpreter ?? const SyncReportInterpreter();

  final SyncScheduler _scheduler;
  final SyncReportInterpreter _interpreter;

  @override
  Future<SyncRunOutcome> foreground(SyncContext context) async {
    final report = await _scheduler.foreground(context);
    return switch (_interpreter.interpret(report)) {
      SyncReportOutcome.succeeded ||
      SyncReportOutcome.partialSuccess =>
        SyncRunOutcome.success,
      SyncReportOutcome.retryScheduled ||
      SyncReportOutcome.offlineDeferred =>
        SyncRunOutcome.retryScheduled,
      SyncReportOutcome.cancelled => SyncRunOutcome.cancelled,
      SyncReportOutcome.alreadyRunning ||
      SyncReportOutcome.authenticationRequired ||
      SyncReportOutcome.needsAttention =>
        SyncRunOutcome.nonRetryableFailure,
    };
  }

  @override
  void cancelRetryForAccount(String accountId) =>
      _scheduler.cancelRetryForAccount(accountId);

  @override
  void dispose() {}
}
