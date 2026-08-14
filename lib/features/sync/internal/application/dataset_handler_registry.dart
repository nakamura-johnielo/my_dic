import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';

class DatasetHandlerRegistry {
  DatasetHandlerRegistry(Iterable<DatasetSyncHandler> handlers)
      : _handlers = {for (final handler in handlers) handler.dataset: handler} {
    if (_handlers.length != handlers.length) {
      throw ArgumentError('duplicate dataset handler');
    }
  }
  final Map<SyncDataset, DatasetSyncHandler> _handlers;
  DatasetSyncHandler? operator [](SyncDataset dataset) => _handlers[dataset];
}
