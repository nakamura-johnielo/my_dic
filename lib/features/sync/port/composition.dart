import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

import 'composition_contract.dart';
import 'dataset_contract.dart';
import '../internal/composition/sync_composition_factory.dart';

export 'composition_contract.dart';

/// Application-owned runtime dependencies required to assemble Sync.
final class SyncDependencies {
  const SyncDependencies({
    required this.database,
    required this.sessionFence,
  });

  final DatabaseProvider database;
  final SessionFence sessionFence;
}

/// Creates the completed Sync infrastructure without framework state.
SyncComposition createSyncComposition({
  required SyncDependencies dependencies,
}) =>
    SyncCompositionFactory.createComposition(
      database: dependencies.database,
      sessionFence: dependencies.sessionFence,
    );

/// Creates the public workflow runner for the registered dataset handlers.
SyncRunner createSyncRunner({
  required SyncDependencies dependencies,
  required Iterable<DatasetSyncHandler> handlers,
}) =>
    SyncCompositionFactory.createRunner(
      database: dependencies.database,
      sessionFence: dependencies.sessionFence,
      handlers: handlers,
    );
