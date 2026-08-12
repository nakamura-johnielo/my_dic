import 'package:my_dic/features/my_word/internal/composition/my_word_ports_factory.dart';
import 'package:my_dic/features/my_word/internal/composition/my_word_sync_factory.dart';
import 'package:my_dic/features/my_word/port/command.dart';
import 'package:my_dic/features/my_word/port/guest_migration.dart';
import 'package:my_dic/features/my_word/port/query.dart';
import 'package:my_dic/features/sync/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';

/// Opaque application-owned services required to assemble MyWord.
enum MyWordDependency { database, outboxWriter }

/// Reads an application-owned dependency requested by the MyWord factory.
typedef MyWordDependencyReader = T Function<T>(MyWordDependency dependency);

/// The complete set of MyWord capabilities used by application workflows.
final class MyWordPorts {
  const MyWordPorts({
    required this.reader,
    required this.commands,
    required this.statusCommands,
    required this.guestMigration,
  });

  final MyWordReaderPort reader;
  final MyWordCommandPort commands;
  final MyWordStatusCommandPort statusCommands;
  final MyWordGuestMigrationPort guestMigration;
}

/// Assembles MyWord from application-owned services without framework state.
MyWordPorts createMyWordPorts(MyWordDependencyReader read) =>
    createInternalMyWordPorts(read);

/// Opaque dependencies used only by MyWord's sync dataset contributions.
enum MyWordSyncDependency { database, firestore, remoteMutationExecutor }

IDatasetSyncHandler createMyWordDatasetSyncHandler(
  SyncDependencyReaderPort read, {
  required ISyncHandlerRuntime runtime,
}) =>
    createInternalMyWordDatasetSyncHandler(read, runtime: runtime);

IDatasetSyncHandler createMyWordStatusDatasetSyncHandler(
  SyncDependencyReaderPort read, {
  required ISyncHandlerRuntime runtime,
}) =>
    createInternalMyWordStatusDatasetSyncHandler(read, runtime: runtime);
