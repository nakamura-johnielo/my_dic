import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/sync_report.dart';

/// A privacy-safe aggregation of a completed sync cycle.
///
/// It deliberately retains counts and outcome categories only. Account IDs,
/// cursors, payloads, and individual entity details stay in [SyncReport].
class SyncReportSummary {
  const SyncReportSummary._({
    required this.duration,
    required this.successCount,
    required this.skippedCount,
    required this.retryableFailureCount,
    required this.nonRetryableFailureCount,
    required this.cancelledCount,
    required this.pushedCount,
    required this.pulledCount,
  });

  factory SyncReportSummary.fromReport(SyncReport report) {
    var successCount = 0;
    var skippedCount = 0;
    var retryableFailureCount = 0;
    var nonRetryableFailureCount = 0;
    var cancelledCount = 0;
    var pushedCount = 0;
    var pulledCount = 0;

    for (final result in report.datasetResults.values) {
      switch (result) {
        case DatasetSyncSuccess():
          successCount++;
          pushedCount += result.pushedCount;
          pulledCount += result.pulledCount;
        case DatasetSyncSkipped():
          skippedCount++;
        case DatasetSyncFailed():
          if (result.retryable) {
            retryableFailureCount++;
          } else {
            nonRetryableFailureCount++;
          }
        case DatasetSyncCancelled():
          cancelledCount++;
      }
    }

    return SyncReportSummary._(
      duration: report.finishedAt.difference(report.startedAt),
      successCount: successCount,
      skippedCount: skippedCount,
      retryableFailureCount: retryableFailureCount,
      nonRetryableFailureCount: nonRetryableFailureCount,
      cancelledCount: cancelledCount,
      pushedCount: pushedCount,
      pulledCount: pulledCount,
    );
  }

  final Duration duration;
  final int successCount;
  final int skippedCount;
  final int retryableFailureCount;
  final int nonRetryableFailureCount;
  final int cancelledCount;
  final int pushedCount;
  final int pulledCount;

  int get datasetCount =>
      successCount +
      skippedCount +
      retryableFailureCount +
      nonRetryableFailureCount +
      cancelledCount;

  bool get hasPartialSuccess =>
      successCount > 0 &&
      (retryableFailureCount > 0 || nonRetryableFailureCount > 0);

  bool get hasRetryableFailure => retryableFailureCount > 0;
  bool get hasNonRetryableFailure => nonRetryableFailureCount > 0;

  bool get isCancelledOnly =>
      cancelledCount > 0 && cancelledCount == datasetCount;
}
