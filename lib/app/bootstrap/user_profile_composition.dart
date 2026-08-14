import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/firebase_providers.dart';
import 'package:my_dic/app/bootstrap/sync_infrastructure_providers.dart';
import 'package:my_dic/core/composition/data_di.dart';
import 'package:my_dic/core/infrastructure/database/shared_preferences/shared_preferences.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/user_profile/port/composition.dart';

final userProfilePortsProvider = Provider<UserProfilePorts>(
  (ref) => createUserProfilePorts(
    dependencies: UserProfileDependencies(
      database: ref.watch(databaseProvider),
      sharedPreferences: ref.watch(sharedPreferencesProvider),
      accountDocuments: ref.watch(firebaseAccountDocumentGatewayProvider),
      remoteMutationExecutor: ref.watch(remoteMutationExecutorProvider),
      outboxWriter: ref.watch(driftOutboxWriterProvider),
      clock: const _AppUserProfileClock(),
    ),
  ),
);

final userProfileDatasetSyncHandlerProvider = Provider<DatasetSyncHandler>(
  (ref) => createUserProfileDatasetSyncHandler(
    dependencies: UserProfileSyncDependencies(
      database: ref.watch(databaseProvider),
      accountDocuments: ref.watch(firebaseAccountDocumentGatewayProvider),
      remoteMutationExecutor: ref.watch(remoteMutationExecutorProvider),
    ),
    runtime: ref.watch(syncHandlerRuntimeProvider),
  ),
);

final class _AppUserProfileClock implements UserProfileClock {
  const _AppUserProfileClock();

  @override
  DateTime now() => DateTime.now();
}
