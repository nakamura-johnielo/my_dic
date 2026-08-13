import 'package:my_dic/features/sync/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_sync_composition_factory.dart';

IDatasetSyncHandler createInternalUserProfileDatasetSyncHandlerFacade(
  SyncDependencyQueryPort read, {
  required ISyncHandlerRuntime runtime,
}) =>
    createInternalUserProfileDatasetSyncHandler(read, runtime: runtime);
