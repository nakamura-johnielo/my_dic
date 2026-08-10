import 'package:my_dic/features/my_word/internal/composition/my_word_sync_composition_factory.dart';
import 'package:my_dic/features/sync/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';

export 'package:my_dic/features/my_word/internal/di/data_di.dart'
    show myWordLocalDataSourceProvider, myWordStatusLocalDataSourceProvider,
        myWordGuestMigrationPortProvider;

/// Pure feature composition for MyWord's two dataset contributions.
enum MyWordSyncDependency { database, firestore, remoteMutationExecutor }

final myWordOutboxWriterDependencyProvider = Provider<OutboxWriter>(
  (_) => throw StateError('OutboxWriter dependency was not supplied.'),
);
final myWordRemoteMutationExecutorDependencyProvider =
    Provider<RemoteMutationExecutor>((_) => throw StateError(
        'RemoteMutationExecutor dependency was not supplied.'));

DatasetSyncHandler createMyWordDatasetSyncHandler(
  SyncDependencyReaderPort read,
  SyncHandlerRuntime runtime,
) => createInternalMyWordDatasetSyncHandler(read, runtime: runtime);

DatasetSyncHandler createMyWordStatusDatasetSyncHandler(
  SyncDependencyReaderPort read,
  SyncHandlerRuntime runtime,
) => createInternalMyWordStatusDatasetSyncHandler(read, runtime: runtime);
