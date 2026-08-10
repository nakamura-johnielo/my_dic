import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/sync/port/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/port/model/sync_report.dart';
import 'package:my_dic/features/sync/port/sync_reason_codes.dart';
import 'package:my_dic/features/sync/internal/application/report/sync_report_summary.dart';

void main() {
  test(
      'summarizes result variants, counts, and duration without report details',
      () {
    final summary = SyncReportSummary.fromReport(_report({
      SyncDataset.myWords:
          const DatasetSyncResult.success(pushedCount: 2, pulledCount: 3),
      SyncDataset.myWordStatus:
          const DatasetSyncResult.skipped(SyncReasonCodes.dependencyFailed),
      SyncDataset.userProfile: const DatasetSyncResult.failed(
        errorCode: SyncReasonCodes.offline,
        retryable: true,
        cursorUnchanged: true,
      ),
      SyncDataset.espJpnWordStatus: const DatasetSyncResult.failed(
        errorCode: SyncReasonCodes.invalidPayload,
        retryable: false,
        cursorUnchanged: true,
      ),
      SyncDataset.jpnEspWordStatus:
          const DatasetSyncResult.cancelled(SyncReasonCodes.sessionChanged),
    }));

    expect(summary.duration, const Duration(seconds: 2));
    expect(summary.datasetCount, 5);
    expect(summary.successCount, 1);
    expect(summary.skippedCount, 1);
    expect(summary.retryableFailureCount, 1);
    expect(summary.nonRetryableFailureCount, 1);
    expect(summary.cancelledCount, 1);
    expect(summary.pushedCount, 2);
    expect(summary.pulledCount, 3);
    expect(summary.hasPartialSuccess, isTrue);
    expect(summary.hasRetryableFailure, isTrue);
    expect(summary.hasNonRetryableFailure, isTrue);
    expect(summary.isCancelledOnly, isFalse);
  });

  test('recognizes a report containing only cancellations', () {
    final summary = SyncReportSummary.fromReport(_report({
      SyncDataset.myWords:
          const DatasetSyncResult.cancelled(SyncReasonCodes.sessionChanged),
      SyncDataset.userProfile:
          const DatasetSyncResult.cancelled(SyncReasonCodes.callerCancelled),
    }));

    expect(summary.isCancelledOnly, isTrue);
    expect(summary.hasPartialSuccess, isFalse);
  });
}

SyncReport _report(Map<SyncDataset, DatasetSyncResult> results) => SyncReport(
      accountId: 'sensitive-account-id',
      startedAt: DateTime.utc(2026, 1, 1),
      finishedAt: DateTime.utc(2026, 1, 1, 0, 0, 2),
      datasetResults: results,
    );
