import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';
import 'package:my_dic/features/sync/application/model/sync_report.dart';
import 'package:my_dic/features/sync/application/report/sync_reason_codes.dart';
import 'package:my_dic/features/sync/infrastructure/telemetry/app_logger_sync_telemetry.dart';

void main() {
  test('serializes only the allowlisted completed-cycle fields', () {
    final telemetry = AppLoggerSyncTelemetry();
    final event = telemetry.serialize(
      trigger: SyncReasonCodes.manual,
      report: SyncReport(
        accountId: 'account-private@example.com',
        startedAt: DateTime.utc(2026, 1, 1),
        finishedAt: DateTime.utc(2026, 1, 1, 0, 0, 0, 123),
        datasetResults: {
          SyncDataset.myWords: const DatasetSyncResult.success(
            pushedCount: 2,
            pulledCount: 4,
            cursor: SyncCursor(
              seconds: 1,
              nanoseconds: 2,
              documentId: 'cursor-document-private',
            ),
          ),
          SyncDataset.userProfile: const DatasetSyncResult.failed(
            errorCode: SyncReasonCodes.transientRemoteFailure,
            retryable: true,
            cursorUnchanged: true,
          ),
        },
      ),
    );

    expect(event.keys, {
      'trigger',
      'duration_ms',
      'outcome',
      'pushed_count',
      'pulled_count',
      'datasets',
    });
    expect(event['trigger'], SyncReasonCodes.manual);
    expect(event['duration_ms'], 123);
    expect(event['outcome'], 'retry_scheduled');
    expect(event['pushed_count'], 2);
    expect(event['pulled_count'], 4);

    final datasets = event['datasets']! as List<Map<String, Object?>>;
    expect(datasets[0], {
      'dataset': 'my_words',
      'result': 'succeeded',
      'pushed_count': 2,
      'pulled_count': 4,
    });
    expect(datasets[1], {
      'dataset': 'user_profile',
      'result': 'failed',
      'error_code': SyncReasonCodes.transientRemoteFailure,
      'retryable': true,
      'cursor_unchanged': true,
    });

    final encoded = jsonEncode(event);
    for (final forbidden in [
      'account-private@example.com',
      'cursor-document-private',
      'accountId',
      'email',
      'token',
      'documentId',
      'payload',
      'entityId',
      'mutationId',
    ]) {
      expect(encoded, isNot(contains(forbidden)));
    }
  });

  test('normalizes unknown trigger and raw result codes', () {
    final event = AppLoggerSyncTelemetry().serialize(
      trigger: 'exception: sensitive token',
      report: SyncReport(
        accountId: 'private',
        startedAt: DateTime.utc(2026),
        finishedAt: DateTime.utc(2026),
        datasetResults: {
          SyncDataset.myWords:
              const DatasetSyncResult.skipped('untrusted raw failure'),
        },
      ),
    );

    expect(event['trigger'], 'unknown');
    final dataset = (event['datasets']! as List<Map<String, Object?>>).single;
    expect(dataset['error_code'], 'unknown');
    expect(jsonEncode(event), isNot(contains('untrusted raw failure')));
  });

  test('emits the named event through its logger boundary', () async {
    String? name;
    Map<String, Object?>? context;
    final telemetry = AppLoggerSyncTelemetry(
      eventLogger: (eventName, eventContext) {
        name = eventName;
        context = eventContext;
      },
    );

    await telemetry.recordCycleCompleted(
      trigger: SyncReasonCodes.sessionReady,
      report: SyncReport(
        accountId: 'private',
        startedAt: DateTime.utc(2026),
        finishedAt: DateTime.utc(2026),
        datasetResults: const {},
      ),
    );

    expect(name, AppLoggerSyncTelemetry.eventName);
    expect(context!['trigger'], SyncReasonCodes.sessionReady);
  });
}
