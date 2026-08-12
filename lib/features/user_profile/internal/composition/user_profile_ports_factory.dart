import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/user_profile/internal/application/usecase/user_usecases.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_lifecycle_remote_factory.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/live_user_profile_adapter.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/drift_user_profile_dao.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/shared_preferenced_user_dao.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/shared_preferenced_user_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_profile_drift_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/user_profile_guest_migration_adapter.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/user_profile_provisioner.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/user_repository.dart';
import 'package:my_dic/features/user_profile/port/composition.dart';

/// Owner-only assembly. Framework and persistence implementations stay here.
UserProfilePorts createInternalUserProfilePorts(
    UserProfileDependencyReader read) {
  final profileLocal = UserProfileDriftDataSource(
    UserProfileDao(read<DatabaseProvider>(UserProfileDependency.database)),
  );
  final userLocal = SharedPreferencesUserDataSource(
    SharedPreferencesUserDao(
      read(UserProfileDependency.sharedPreferences),
    ),
  );
  final repository = UserRepository(
    userLocal,
    profileLocal,
    read<IOutboxWriter>(UserProfileDependency.outboxWriter),
  );
  return UserProfilePorts(
    ensureUserProfile: EnsureUserExistsInteractor(UserProfileProvisioner(
      createInternalLifecycleFirebaseUserRemoteDataSource(
        read<IRemoteMutationExecutor>(
          UserProfileDependency.remoteMutationExecutor,
        ),
      ),
      userLocal,
      profileLocal,
    )),
    liveUserProfile: LiveUserProfileAdapter(profileLocal),
    guestMigration: UserProfileGuestMigrationAdapter(profileLocal),
    updateUserProfile: UpdateUserInteractor(repository),
  );
}
