import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/firebase/firebase_account_document_namespace.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/user_profile/internal/application/user_profile_application_service.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_lifecycle_remote_factory.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local_user_profile_query_service.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/drift_user_profile_dao.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/shared_preferences_user_dao.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/shared_preferences_user_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_profile_drift_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/user_profile_guest_migration_service.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/user_profile_provisioning_service.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local_first_user_profile_repository.dart';
import 'package:my_dic/features/user_profile/port/composition_contract.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 所有者専用の組み立てです。フレームワークと永続化の実装はここに留めます。
UserProfilePorts createInternalUserProfilePorts({
  required DatabaseProvider database,
  required SharedPreferences sharedPreferences,
  required FirebaseAccountDocumentGateway accountDocuments,
  required RemoteMutationExecutor remoteMutationExecutor,
  required OutboxWriter outboxWriter,
  required UserProfileClock clock,
}) {
  final profileLocal = UserProfileDriftDataSource(UserProfileDao(database));
  final userLocal = SharedPreferencesUserDataSource(
    SharedPreferencesUserDao(sharedPreferences),
  );
  final repository = LocalFirstUserProfileRepository(
    userLocal,
    profileLocal,
    outboxWriter,
  );
  final provisioning = UserProfileProvisioningService(
    createInternalLifecycleFirebaseUserRemoteDataSource(
      accountDocuments: accountDocuments,
      remoteMutationExecutor: remoteMutationExecutor,
    ),
    userLocal,
    profileLocal,
  );
  return UserProfilePorts(
    query: LocalUserProfileQueryService(profileLocal),
    commands: UserProfileApplicationService(
      provisioning: provisioning,
      repository: repository,
    ),
    guestMigration: UserProfileGuestMigrationService(
      profileLocal,
      outboxWriter,
      clock,
    ),
  );
}
