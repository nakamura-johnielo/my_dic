import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/firebase/firebase_account_document_namespace.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/firebase_user_remote_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/firebase_user_profile_dao.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/drift_user_profile_dao.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_profile_drift_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/sync/user_profile_dataset_sync_service.dart';

DatasetSyncHandler createInternalUserProfileDatasetSyncHandler({
  required DatabaseProvider database,
  required FirebaseAccountDocumentGateway accountDocuments,
  required RemoteMutationExecutor remoteMutationExecutor,
  required SyncHandlerRuntime runtime,
}) =>
    DatasetSyncService(
      adapter: UserProfileDatasetSyncService(
        local: UserProfileDriftDataSource(UserProfileDao(database)),
        remote: FirebaseUserRemoteDataSource(
          FirebaseUserProfileDao(accountDocuments, remoteMutationExecutor),
        ),
      ),
      runtime: runtime,
    );
