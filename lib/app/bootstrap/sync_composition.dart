import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/firebase_providers.dart';
import 'package:my_dic/app/bootstrap/my_word_composition.dart';
import 'package:my_dic/app/bootstrap/sync_infrastructure_providers.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/sync/port/composition.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/sync_runner.dart';
import 'package:my_dic/features/user_profile/port/composition.dart' as user;
import 'package:my_dic/features/word_status/port/composition.dart'
    as word_status;

export 'sync_infrastructure_providers.dart';

/// Registry assembly registers completed MyWord capabilities while features
/// awaiting migration continue to use their public composition factories.
final syncDatasetHandlersProvider = Provider<List<IDatasetSyncHandler>>((ref) {
  final runtime = ref.watch(syncHandlerRuntimeProvider);
  return [
    word_status.createEspJpnWordStatusDatasetSyncHandler(
      _featureQueryPort(ref),
      runtime: runtime,
    ),
    word_status.createJpnEspWordStatusDatasetSyncHandler(
      _featureQueryPort(ref),
      runtime: runtime,
    ),
    ref.watch(myWordDatasetSyncHandlerProvider),
    ref.watch(myWordStatusDatasetSyncHandlerProvider),
    user.createUserProfileDatasetSyncHandler(
      _featureQueryPort(ref),
      runtime: runtime,
    ),
  ];
});

/// The only Sync entry point consumed by app workflows.
final syncRunnerProvider = Provider<ISyncRunner>((ref) {
  final runner = createSyncRunner(
    _syncQueryPort(ref),
    ref.watch(syncDatasetHandlersProvider),
  );
  ref.onDispose(runner.dispose);
  return runner;
});

T _readSyncDependency<T>(Ref ref, Object dependency) {
  if (identical(dependency, SyncCompositionDependencies.database)) {
    return ref.watch(databaseProvider) as T;
  }
  if (identical(dependency, SyncCompositionDependencies.sessionFence)) {
    return ref.watch(syncSessionFenceProvider) as T;
  }
  throw ArgumentError.value(dependency, 'dependency');
}

SyncDependencyQueryPort _syncQueryPort(Ref ref) {
  T read<T>(Object dependency) => _readSyncDependency<T>(ref, dependency);
  return read;
}

SyncDependencyQueryPort _featureQueryPort(Ref ref) {
  T read<T>(Object dependency) => _readFeatureDependency<T>(ref, dependency);
  return read;
}

/// Resolver-backed features request only neutral app capabilities through
/// their public opaque keys; feature internal types never enter this registry.
T _readFeatureDependency<T>(Ref ref, Object dependency) {
  final isDatabase = switch (dependency) {
    user.UserProfileSyncDependency.database ||
    word_status.WordStatusSyncDependency.database =>
      true,
    _ => false,
  };
  if (isDatabase) return ref.watch(databaseProvider) as T;
  final isFirestore = switch (dependency) {
    user.UserProfileSyncDependency.firestore ||
    word_status.WordStatusSyncDependency.firestore =>
      true,
    _ => false,
  };
  if (isFirestore) return ref.watch(firestoreDBProvider) as T;
  final isMutationExecutor = switch (dependency) {
    user.UserProfileSyncDependency.remoteMutationExecutor ||
    word_status.WordStatusSyncDependency.remoteMutationExecutor =>
      true,
    _ => false,
  };
  if (isMutationExecutor) return ref.watch(remoteMutationExecutorProvider) as T;
  throw ArgumentError.value(dependency, 'dependency');
}
