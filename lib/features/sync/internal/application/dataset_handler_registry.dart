import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';

class DatasetHandlerRegistry {
  DatasetHandlerRegistry(Iterable<IDatasetSyncHandler> handlers)
      : _handlers = {for (final handler in handlers) handler.dataset: handler} {
    if (_handlers.length != handlers.length) {
      throw ArgumentError('duplicate dataset handler');
    }
  }
  final Map<SyncDataset, IDatasetSyncHandler> _handlers;
  IDatasetSyncHandler? operator [](SyncDataset dataset) => _handlers[dataset];
}
