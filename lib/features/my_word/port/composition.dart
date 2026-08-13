import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/my_word/internal/composition/my_word_ports_factory.dart';
import 'package:my_dic/features/my_word/internal/composition/my_word_sync_factory.dart';
import 'package:my_dic/features/my_word/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';

export 'composition_contract.dart';

/// Application-owned services required to assemble MyWord capabilities.
final class MyWordDependencies {
  const MyWordDependencies({
    required this.database,
    required this.outboxWriter,
  });

  final DatabaseProvider database;
  final IOutboxWriter outboxWriter;
}

/// Application-owned services required by MyWord dataset synchronization.
final class MyWordSyncDependencies {
  const MyWordSyncDependencies({
    required this.database,
    required this.firestore,
    required this.remoteMutationExecutor,
  });

  final DatabaseProvider database;
  final FirebaseFirestore firestore;
  final IRemoteMutationExecutor remoteMutationExecutor;
}

/// Assembles MyWord from application-owned services without framework state.
MyWordPorts createMyWordPorts({
  required MyWordDependencies dependencies,
}) =>
    createInternalMyWordPorts(
      database: dependencies.database,
      outboxWriter: dependencies.outboxWriter,
    );

IDatasetSyncHandler createMyWordDatasetSyncHandler({
  required MyWordSyncDependencies dependencies,
  required ISyncHandlerRuntime runtime,
}) =>
    createInternalMyWordDatasetSyncHandler(
      database: dependencies.database,
      firestore: dependencies.firestore,
      remoteMutationExecutor: dependencies.remoteMutationExecutor,
      runtime: runtime,
    );

IDatasetSyncHandler createMyWordStatusDatasetSyncHandler({
  required MyWordSyncDependencies dependencies,
  required ISyncHandlerRuntime runtime,
}) =>
    createInternalMyWordStatusDatasetSyncHandler(
      database: dependencies.database,
      firestore: dependencies.firestore,
      remoteMutationExecutor: dependencies.remoteMutationExecutor,
      runtime: runtime,
    );
