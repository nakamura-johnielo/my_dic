import 'package:my_dic/features/sync/port/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/port/model/sync_report.dart';
import 'package:my_dic/features/sync/port/sync_reason_codes.dart';
import 'sync_report_summary.dart';

/// [SyncReport] から導出した UI で安全な結果です。
enum SyncReportOutcome {
  cancelled,
  alreadyRunning,
  authenticationRequired,
  needsAttention,
  offlineDeferred,
  retryScheduled,
  partialSuccess,
  succeeded,
}

/// レポートの詳細を公開せず、文書化された結果の優先順位を適用します。
class SyncReportInterpreter {
  const SyncReportInterpreter();

  SyncReportOutcome interpret(SyncReport report) {
    final summary = SyncReportSummary.fromReport(report);
    if (summary.isCancelledOnly) {
      return SyncReportOutcome.cancelled;
    }
    if (_allSkippedFor(report, SyncReasonCodes.syncAlreadyRunning)) {
      return SyncReportOutcome.alreadyRunning;
    }
    if (_hasFailureCode(report, SyncReasonCodes.authRequired)) {
      return SyncReportOutcome.authenticationRequired;
    }
    if (summary.hasNonRetryableFailure) {
      return SyncReportOutcome.needsAttention;
    }
    if (_hasRetryableFailureCode(report, SyncReasonCodes.offline)) {
      return SyncReportOutcome.offlineDeferred;
    }
    if (summary.hasRetryableFailure) {
      return SyncReportOutcome.retryScheduled;
    }
    if (summary.hasPartialSuccess) {
      return SyncReportOutcome.partialSuccess;
    }
    if (summary.successCount == summary.datasetCount &&
        summary.datasetCount > 0) {
      return SyncReportOutcome.succeeded;
    }

    // 成功したデータセットのないスキップ済みハンドラーは、対応可能な警告です。
    return SyncReportOutcome.needsAttention;
  }

  bool _allSkippedFor(SyncReport report, String reason) =>
      report.datasetResults.isNotEmpty &&
      report.datasetResults.values.every(
        (result) => result is DatasetSyncSkipped && result.reason == reason,
      );

  bool _hasFailureCode(SyncReport report, String code) =>
      report.datasetResults.values
          .whereType<DatasetSyncFailed>()
          .any((result) => result.errorCode == code);

  bool _hasRetryableFailureCode(SyncReport report, String code) =>
      report.datasetResults.values
          .whereType<DatasetSyncFailed>()
          .any((result) => result.retryable && result.errorCode == code);
}
