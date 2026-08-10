import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/port/dataset_sync_adapter.dart';
import 'package:my_dic/features/sync/port/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/word_status/port/composition.dart';

void main() {
  test('creates distinct handlers from the public WordStatus factories', () {
    final runtime = _Runtime();
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final WordStatusSyncDependencyReaderPort read =
        <T>(Object dependency) => _readDependency<T>(dependency, database);

    final esp = createEspJpnWordStatusDatasetSyncHandler(
      read,
      runtime: runtime,
    );
    final jpn = createJpnEspWordStatusDatasetSyncHandler(
      read,
      runtime: runtime,
    );

    expect(esp.dataset, SyncDataset.espJpnWordStatus);
    expect(jpn.dataset, SyncDataset.jpnEspWordStatus);
  });
}

T _readDependency<T>(Object dependency, DatabaseProvider database) =>
    switch (dependency) {
      WordStatusSyncDependency.database => database as T,
      WordStatusSyncDependency.firestore => _Firestore() as T,
      WordStatusSyncDependency.remoteMutationExecutor =>
        _RemoteMutations() as T,
      _ => throw ArgumentError.value(dependency, 'dependency'),
    };

final class _Runtime implements SyncHandlerRuntime {
  @override
  Future<DatasetSyncResult> run(
    SyncContext context,
    DatasetSyncAdapter adapter,
  ) async =>
      const DatasetSyncResult.cancelled('test');
}

final class _Firestore extends Mock implements FirebaseFirestore {}

final class _RemoteMutations extends Mock implements RemoteMutationExecutor {}
