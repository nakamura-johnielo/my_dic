import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/dataset_handler_registry.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/model/sync_report.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/port/dataset_sync_handler.dart';

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
    );
    payload['value'] = 2;
    expect(mutation.payload['value'], 1);
    expect(() => mutation.payload['x'] = 2, throwsUnsupportedError);
    final report = SyncReport(
      accountId: 'a',
      startedAt: DateTime.utc(2026),
      finishedAt: DateTime.utc(2026),
      datasetResults: {
        SyncDataset.myWords: const DatasetSyncResult.skipped('test')
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
