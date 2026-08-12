import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/drift_user_profile_dao.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_profile_drift_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_sync_remote_factory.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/sync/user_profile_dataset_sync_adapter.dart';
import 'package:my_dic/features/user_profile/port/composition.dart';

DatasetSyncHandler createInternalUserProfileDatasetSyncHandler(
        SyncDependencyReaderPort read,
        {required SyncHandlerRuntime runtime}) =>
    AdapterDatasetSyncHandler(
        adapter: UserProfileDatasetSyncAdapter(
            local: UserProfileDriftDataSource(UserProfileDao(
                read<DatabaseProvider>(UserProfileSyncDependency.database))),
            remote: createInternalFirebaseUserProfileRemoteDataSource(read)),
        runtime: runtime);
