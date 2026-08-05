import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';

abstract interface class DatasetSyncHandler {
  SyncDataset get dataset;
  Future<DatasetSyncResult> run(SyncContext context);
}
