import 'package:my_dic/features/sync/port/sync_dataset.dart';

/// テーブル依存関係順にソートされたSyncDatasetのリストを返す
class DatasetPlan {
  const DatasetPlan(this.datasets, {this.dependencies = const {}});
  final List<SyncDataset> datasets;
  final Map<SyncDataset, Set<SyncDataset>> dependencies;
  static const localFirst = DatasetPlan(
    SyncDataset.values,
    dependencies: {
      SyncDataset.myWordStatus: {SyncDataset.myWords},
    },
  );

  List<SyncDataset> orderedDatasets() {
    final allowed = datasets.toSet();
    final visiting = <SyncDataset>{};
    final visited = <SyncDataset>{};
    final result = <SyncDataset>[];
    void visit(SyncDataset dataset) {
      if (visited.contains(dataset)) return;
      if (!visiting.add(dataset)) {
        throw StateError(
            'dataset dependency cycle contains ${dataset.stableId}');
      }
      for (final dependency in dependencies[dataset] ?? const {}) {
        if (!allowed.contains(dependency)) {
          throw StateError(
              '${dataset.stableId} depends on an unplanned dataset ${dependency.stableId}');
        }
        visit(dependency);
      }
      visiting.remove(dataset);
      visited.add(dataset);
      result.add(dataset);
    }

    for (final dataset in datasets) {
      visit(dataset);
    }
    return List.unmodifiable(result);
  }
}
