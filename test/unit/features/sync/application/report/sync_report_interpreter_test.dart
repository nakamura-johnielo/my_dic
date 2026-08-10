import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/sync/port/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/port/model/sync_report.dart';
import 'package:my_dic/features/sync/internal/application/report/sync_report_interpreter.dart';
import 'package:my_dic/features/sync/port/sync_reason_codes.dart';

void main() {
  const interpreter = SyncReportInterpreter();

  test('uses the documented outcome precedence', () {
    expect(
      interpreter.interpret(_report({
        SyncDataset.myWords:
            const DatasetSyncResult.cancelled(SyncReasonCodes.sessionChanged),
      })),
      SyncReportOutcome.cancelled,
    );
    expect(
      interpreter.interpret(_report({
        SyncDataset.myWords:
            const DatasetSyncResult.skipped(SyncReasonCodes.syncAlreadyRunning),
      })),
      SyncReportOutcome.alreadyRunning,
    );
    expect(
      interpreter.interpret(_report({
        SyncDataset.myWords: const DatasetSyncResult.failed(
          errorCode: SyncReasonCodes.authRequired,
          retryable: true,
          cursorUnchanged: true,
        ),
        SyncDataset.userProfile: const DatasetSyncResult.failed(
          errorCode: SyncReasonCodes.invalidPayload,
          retryable: false,
          cursorUnchanged: true,
        ),
      })),
      SyncReportOutcome.authenticationRequired,
    );
    expect(
      interpreter.interpret(_report({
        SyncDataset.myWords: const DatasetSyncResult.failed(
          errorCode: SyncReasonCodes.invalidPayload,
          retryable: false,
          cursorUnchanged: true,
        ),
      })),
      SyncReportOutcome.needsAttention,
    );
  });

  test('distinguishes offline, retryable, partial, and full success', () {
    expect(
      interpreter.interpret(_report({
        SyncDataset.myWords: const DatasetSyncResult.failed(
          errorCode: SyncReasonCodes.offline,
          retryable: true,
          cursorUnchanged: true,
        ),
      })),
      SyncReportOutcome.offlineDeferred,
    );
    expect(
      interpreter.interpret(_report({
        SyncDataset.myWords: const DatasetSyncResult.failed(
          errorCode: SyncReasonCodes.transientRemoteFailure,
          retryable: true,
          cursorUnchanged: true,
        ),
      })),
      SyncReportOutcome.retryScheduled,
    );
    expect(
      interpreter.interpret(_report({
        SyncDataset.myWords:
            const DatasetSyncResult.success(pushedCount: 1, pulledCount: 0),
        SyncDataset.userProfile: const DatasetSyncResult.failed(
          errorCode: SyncReasonCodes.transientRemoteFailure,
          retryable: true,
          cursorUnchanged: true,
        ),
      })),
      SyncReportOutcome.retryScheduled,
    );
    expect(
      interpreter.interpret(_report({
        SyncDataset.myWords:
            const DatasetSyncResult.success(pushedCount: 1, pulledCount: 2),
      })),
      SyncReportOutcome.succeeded,
    );
  });

  test('treats an isolated unavailable handler as an actionable warning', () {
    expect(
      interpreter.interpret(_report({
        SyncDataset.myWords:
            const DatasetSyncResult.skipped(SyncReasonCodes.handlerUnavailable),
      })),
      SyncReportOutcome.needsAttention,
    );
  });
}

SyncReport _report(Map<SyncDataset, DatasetSyncResult> results) => SyncReport(
      accountId: 'sensitive-account-id',
      startedAt: DateTime.utc(2026, 1, 1),
      finishedAt: DateTime.utc(2026, 1, 1, 0, 0, 1),
      datasetResults: results,
    );
