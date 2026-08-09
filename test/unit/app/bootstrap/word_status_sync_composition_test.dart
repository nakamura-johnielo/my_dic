import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/bootstrap/word_status_composition.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/port/dataset_sync_handler.dart';

void main() {
  test('publishes distinct handlers for the two WordStatus datasets', () {
    final esp = _Handler(SyncDataset.espJpnWordStatus);
    final jpn = _Handler(SyncDataset.jpnEspWordStatus);
    final container = ProviderContainer(overrides: [
      espJpnWordStatusDatasetSyncHandlerProvider.overrideWithValue(esp),
      jpnEspWordStatusDatasetSyncHandlerProvider.overrideWithValue(jpn),
    ]);
    addTearDown(container.dispose);

    expect(container.read(wordStatusDatasetSyncHandlersProvider), [esp, jpn]);
  });
}

final class _Handler implements DatasetSyncHandler {
  const _Handler(this.dataset);

  @override
  final SyncDataset dataset;

  @override
  Future<DatasetSyncResult> run(SyncContext context) async =>
      const DatasetSyncResult.cancelled('test');
}
