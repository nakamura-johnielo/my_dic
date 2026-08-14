import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/features/sync/port/dataset_sync_gateway.dart';
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
    final dependencies = WordStatusSyncDependencies(
      database: database,
      remoteDocuments: _RemoteDocuments(),
      remoteMutationExecutor: _RemoteMutations(),
    );

    final esp = createEspJpnWordStatusDatasetSyncHandler(
      dependencies: dependencies,
      runtime: runtime,
    );
    final jpn = createJpnEspWordStatusDatasetSyncHandler(
      dependencies: dependencies,
      runtime: runtime,
    );

    expect(esp.dataset, SyncDataset.espJpnWordStatus);
    expect(jpn.dataset, SyncDataset.jpnEspWordStatus);
  });
}

final class _Runtime implements SyncHandlerRuntime {
  @override
  Future<DatasetSyncResult> run(
    SyncContext context,
    DatasetSyncGateway adapter,
  ) async =>
      const DatasetSyncResult.cancelled('test');
}

final class _RemoteDocuments extends Mock
    implements FirebaseAccountNestedDocumentGateway {}

final class _RemoteMutations extends Mock implements RemoteMutationExecutor {}
