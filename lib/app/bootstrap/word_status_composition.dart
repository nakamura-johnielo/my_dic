import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/firebase_providers.dart';
import 'package:my_dic/app/bootstrap/sync_infrastructure_providers.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/word_status/port/composition.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

final wordStatusPortsProvider = Provider<WordStatusPorts>(
  (ref) => createWordStatusPorts(
    dependencies: WordStatusDependencies(
      database: ref.watch(databaseProvider),
      outboxWriter: ref.watch(driftOutboxWriterProvider),
      clock: const _AppWordStatusClock(),
    ),
  ),
);

final wordStatusGuestMigrationProvider = Provider<WordStatusGuestMigrationPort>(
  (ref) => ref.watch(wordStatusPortsProvider).guestMigration,
);

final espJpnWordStatusDatasetSyncHandlerProvider =
    Provider<DatasetSyncHandler>(
  (ref) => createEspJpnWordStatusDatasetSyncHandler(
    dependencies: WordStatusSyncDependencies(
      database: ref.watch(databaseProvider),
      remoteDocuments: FirestoreAccountNestedDocumentGateway(
        ref.watch(firestoreDBProvider),
      ),
      remoteMutationExecutor: ref.watch(remoteMutationExecutorProvider),
    ),
    runtime: ref.watch(syncHandlerRuntimeProvider),
  ),
);

final jpnEspWordStatusDatasetSyncHandlerProvider =
    Provider<DatasetSyncHandler>(
  (ref) => createJpnEspWordStatusDatasetSyncHandler(
    dependencies: WordStatusSyncDependencies(
      database: ref.watch(databaseProvider),
      remoteDocuments: FirestoreAccountNestedDocumentGateway(
        ref.watch(firestoreDBProvider),
      ),
      remoteMutationExecutor: ref.watch(remoteMutationExecutorProvider),
    ),
    runtime: ref.watch(syncHandlerRuntimeProvider),
  ),
);

final class _AppWordStatusClock implements WordStatusClock {
  const _AppWordStatusClock();

  @override
  DateTime now() => DateTime.now();
}
