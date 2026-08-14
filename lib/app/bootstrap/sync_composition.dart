import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/my_word_composition.dart';
import 'package:my_dic/app/bootstrap/sync_infrastructure_providers.dart';
import 'package:my_dic/app/bootstrap/word_status_composition.dart';
import 'package:my_dic/app/bootstrap/user_profile_composition.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/sync/port/composition.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

export 'sync_infrastructure_providers.dart';

/// Registry assembly registers completed MyWord capabilities while features
/// awaiting migration continue to use their public composition factories.
final syncDatasetHandlersProvider = Provider<List<DatasetSyncHandler>>((ref) {
  return [
    ref.watch(espJpnWordStatusDatasetSyncHandlerProvider),
    ref.watch(jpnEspWordStatusDatasetSyncHandlerProvider),
    ref.watch(myWordDatasetSyncHandlerProvider),
    ref.watch(myWordStatusDatasetSyncHandlerProvider),
    ref.watch(userProfileDatasetSyncHandlerProvider),
  ];
});

/// The only Sync entry point consumed by app workflows.
final syncRunnerProvider = Provider<SyncRunner>((ref) {
  final runner = createSyncRunner(
    dependencies: SyncDependencies(
      database: ref.watch(databaseProvider),
      sessionFence: ref.watch(syncSessionFenceProvider),
    ),
    handlers: ref.watch(syncDatasetHandlersProvider),
  );
  ref.onDispose(runner.dispose);
  return runner;
});
