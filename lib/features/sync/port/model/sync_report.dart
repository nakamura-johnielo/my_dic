import 'dart:collection';
import '../sync_dataset.dart';
import 'dataset_sync_result.dart';

class SyncReport {
  SyncReport(
      {required this.accountId,
      required this.startedAt,
      required this.finishedAt,
      required Map<SyncDataset, DatasetSyncResult> datasetResults})
      : datasetResults = UnmodifiableMapView(Map.of(datasetResults));
  final String accountId;
  final DateTime startedAt;
  final DateTime finishedAt;
  final Map<SyncDataset, DatasetSyncResult> datasetResults;
}
