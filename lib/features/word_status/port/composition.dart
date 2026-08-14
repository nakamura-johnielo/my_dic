import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/word_status/internal/composition/word_status_composition_factory.dart';
import 'package:my_dic/features/word_status/port/composition_contract.dart';

export 'composition_contract.dart';

final class WordStatusDependencies {
  const WordStatusDependencies({
    required this.database,
    required this.outboxWriter,
    required this.clock,
  });

  final DatabaseProvider database;
  final OutboxWriter outboxWriter;
  final WordStatusClock clock;
}

final class WordStatusSyncDependencies {
  const WordStatusSyncDependencies({
    required this.database,
    required this.remoteDocuments,
    required this.remoteMutationExecutor,
  });

  final DatabaseProvider database;
  final FirebaseAccountNestedDocumentGateway remoteDocuments;
  final RemoteMutationExecutor remoteMutationExecutor;
}

WordStatusPorts createWordStatusPorts({
  required WordStatusDependencies dependencies,
}) =>
    createInternalWordStatusPorts(
      database: dependencies.database,
      outboxWriter: dependencies.outboxWriter,
      clock: dependencies.clock,
    );

DatasetSyncHandler createEspJpnWordStatusDatasetSyncHandler({
  required WordStatusSyncDependencies dependencies,
  required SyncHandlerRuntime runtime,
}) =>
    createInternalEspJpnWordStatusDatasetSyncHandler(
      database: dependencies.database,
      remoteDocuments: dependencies.remoteDocuments,
      remoteMutationExecutor: dependencies.remoteMutationExecutor,
      runtime: runtime,
    );

DatasetSyncHandler createJpnEspWordStatusDatasetSyncHandler({
  required WordStatusSyncDependencies dependencies,
  required SyncHandlerRuntime runtime,
}) =>
    createInternalJpnEspWordStatusDatasetSyncHandler(
      database: dependencies.database,
      remoteDocuments: dependencies.remoteDocuments,
      remoteMutationExecutor: dependencies.remoteMutationExecutor,
      runtime: runtime,
    );
