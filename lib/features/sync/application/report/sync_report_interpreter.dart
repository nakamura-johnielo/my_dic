import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/sync_report.dart';
import 'package:my_dic/features/sync/application/report/sync_reason_codes.dart';
import 'package:my_dic/features/sync/application/report/sync_report_summary.dart';

/// UI-safe outcomes derived from a [SyncReport].
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

/// Applies the documented outcome precedence without exposing report details.
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

    // A skipped handler without a successful dataset is an actionable warning.
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
