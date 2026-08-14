import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/firebase_providers.dart';
import 'package:my_dic/app/bootstrap/sync_infrastructure_providers.dart';
import 'package:my_dic/core/composition/data_di.dart';
import 'package:my_dic/features/my_word/port/composition.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

/// App-owned Riverpod lifetime around MyWord's framework-free factory.
final myWordPortsProvider = Provider<MyWordPorts>(
  (ref) => createMyWordPorts(
    dependencies: MyWordDependencies(
      database: ref.watch(databaseProvider),
      outboxWriter: ref.watch(driftOutboxWriterProvider),
    ),
  ),
);

final myWordDatasetSyncHandlerProvider = Provider<DatasetSyncHandler>(
  (ref) => createMyWordDatasetSyncHandler(
    dependencies: MyWordSyncDependencies(
      database: ref.watch(databaseProvider),
      remoteDocuments: FirestoreAccountNestedDocumentGateway(
        ref.watch(firestoreDBProvider),
      ),
      remoteMutationExecutor: ref.watch(remoteMutationExecutorProvider),
    ),
    runtime: ref.watch(syncHandlerRuntimeProvider),
  ),
);

final myWordStatusDatasetSyncHandlerProvider = Provider<DatasetSyncHandler>(
  (ref) => createMyWordStatusDatasetSyncHandler(
    dependencies: MyWordSyncDependencies(
      database: ref.watch(databaseProvider),
      remoteDocuments: FirestoreAccountNestedDocumentGateway(
        ref.watch(firestoreDBProvider),
      ),
      remoteMutationExecutor: ref.watch(remoteMutationExecutorProvider),
    ),
    runtime: ref.watch(syncHandlerRuntimeProvider),
  ),
);
