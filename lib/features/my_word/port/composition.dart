import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/features/my_word/internal/composition/my_word_composition_factory.dart';
import 'package:my_dic/features/my_word/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

export 'composition_contract.dart';

/// Application-owned services required to assemble MyWord capabilities.
final class MyWordDependencies {
  const MyWordDependencies({
    required this.database,
    required this.outboxWriter,
  });

  final DatabaseProvider database;
  final OutboxWriter outboxWriter;
}

/// Application-owned services required by MyWord dataset synchronization.
final class MyWordSyncDependencies {
  const MyWordSyncDependencies({
    required this.database,
    required this.remoteDocuments,
    required this.remoteMutationExecutor,
  });

  final DatabaseProvider database;
  final FirebaseAccountNestedUpdatedDocumentGateway remoteDocuments;
  final RemoteMutationExecutor remoteMutationExecutor;
}

/// Assembles MyWord from application-owned services without framework state.
MyWordPorts createMyWordPorts({
  required MyWordDependencies dependencies,
}) =>
    createInternalMyWordPorts(
      database: dependencies.database,
      outboxWriter: dependencies.outboxWriter,
    );

DatasetSyncHandler createMyWordDatasetSyncHandler({
  required MyWordSyncDependencies dependencies,
  required SyncHandlerRuntime runtime,
}) =>
    createInternalMyWordDatasetSyncHandler(
      database: dependencies.database,
      remoteDocuments: dependencies.remoteDocuments,
      remoteMutationExecutor: dependencies.remoteMutationExecutor,
      runtime: runtime,
    );

DatasetSyncHandler createMyWordStatusDatasetSyncHandler({
  required MyWordSyncDependencies dependencies,
  required SyncHandlerRuntime runtime,
}) =>
    createInternalMyWordStatusDatasetSyncHandler(
      database: dependencies.database,
      remoteDocuments: dependencies.remoteDocuments,
      remoteMutationExecutor: dependencies.remoteMutationExecutor,
      runtime: runtime,
    );
