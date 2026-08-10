import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/sync/internal/application/dataset_handler_registry.dart';
import 'package:my_dic/features/sync/port/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/port/model/sync_cursor.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/model/sync_report.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/sync_reason_codes.dart';

class _Handler implements DatasetSyncHandler {
  _Handler(this.dataset);
  @override
  final SyncDataset dataset;
  @override
  Future<DatasetSyncResult> run(SyncContext context) async =>
      const DatasetSyncResult.success(pushedCount: 0, pulledCount: 0);
}

void main() {
  test('dataset stable IDs and order are protocol constants', () {
    expect(SyncDataset.values.map((e) => e.stableId), [
      'esp_jpn_word_status',
      'jpn_esp_word_status',
      'my_words',
      'my_word_status',
      'user_profile',
    ]);
    for (final dataset in SyncDataset.values) {
      expect(SyncDataset.fromStableId(dataset.stableId), dataset);
    }
  });

  test('sync report reason codes are protocol constants', () {
    expect(SyncReasonCodes.syncAlreadyRunning, 'sync_already_running');
    expect(SyncReasonCodes.dependencyFailed, 'dependency_failed');
    expect(SyncReasonCodes.handlerUnavailable, 'handler_unavailable');
    expect(SyncReasonCodes.sessionChanged, 'session_changed');
    expect(SyncReasonCodes.callerCancelled, 'caller_cancelled');
    expect(SyncReasonCodes.offline, 'offline');
    expect(SyncReasonCodes.authRequired, 'auth_required');
    expect(SyncReasonCodes.invalidPayload, 'invalid_payload');
    expect(SyncReasonCodes.transientRemoteFailure, 'transient_remote_failure');
    expect(SyncReasonCodes.handlerException, 'handler_exception');
    expect(SyncReasonCodes.sessionReady, 'session_ready');
    expect(SyncReasonCodes.appResumed, 'app_resumed');
    expect(SyncReasonCodes.postGuestMigration, 'post_guest_migration');
    expect(SyncReasonCodes.manual, 'manual');
    expect(SyncReasonCodes.retryDue, 'retry_due');
  });

  test('cursor orders equal timestamps by nanoseconds then document ID', () {
    const first = SyncCursor(seconds: 1, nanoseconds: 2, documentId: 'a');
    const second = SyncCursor(seconds: 1, nanoseconds: 2, documentId: 'b');
    expect(first.compareTo(second), lessThan(0));
  });

  test('mutation and report do not expose mutable payload collections', () {
    final payload = <String, Object?>{'value': 1};
    final mutation = SyncMutation(
      mutationId: 'm',
      accountId: 'a',
      dataset: SyncDataset.myWords,
      entityId: 'e',
      operation: SyncMutationOperation.patch,
      payload: payload,
      fieldMask: const ['value'],
      localRevision: 1,
      clientUpdatedAt: DateTime.utc(2026),
    );
    payload['value'] = 2;
    expect(mutation.payload['value'], 1);
    expect(() => mutation.payload['x'] = 2, throwsUnsupportedError);
    final report = SyncReport(
      accountId: 'a',
      startedAt: DateTime.utc(2026),
      finishedAt: DateTime.utc(2026),
      datasetResults: {
        SyncDataset.myWords:
            const DatasetSyncResult.skipped(SyncReasonCodes.handlerUnavailable)
      },
    );
    expect(() => report.datasetResults.clear(), throwsUnsupportedError);
  });

  test('registry rejects duplicate dataset handlers', () {
    expect(
        () => DatasetHandlerRegistry(
            [_Handler(SyncDataset.myWords), _Handler(SyncDataset.myWords)]),
        throwsArgumentError);
  });
}
