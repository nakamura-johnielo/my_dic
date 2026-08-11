import 'package:my_dic/features/sync/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';
import 'package:my_dic/features/user_profile/internal/composition/user_profile_ports_factory.dart';
import 'package:my_dic/features/user_profile/internal/composition/user_profile_sync_factory.dart';
import 'auth_lifecycle.dart';
import 'guest_migration.dart';
import 'live_user_profile.dart';
import 'user_profile.dart';

/// Opaque app capabilities requested by UserProfile's owner factory.
enum UserProfileDependency {
  database,
  sharedPreferences,
  remoteMutationExecutor,
  outboxWriter,
}

typedef UserProfileDependencyReader = T Function<T>(
  UserProfileDependency dependency,
);

/// Lifecycle subset used by the app's authentication workflow.
final class UserLifecyclePorts {
  const UserLifecyclePorts({required this.ensureUserProfile});

  final EnsureUserProfilePort ensureUserProfile;
}

/// The complete set of UserProfile capabilities consumed by app workflows.
final class UserProfilePorts {
  const UserProfilePorts({
    required this.ensureUserProfile,
    required this.liveUserProfile,
    required this.guestMigration,
    required this.updateUserProfile,
  });

  final EnsureUserProfilePort ensureUserProfile;
  final LiveUserProfilePort liveUserProfile;
  final UserProfileGuestMigrationPort guestMigration;
  final UpdateUserProfilePort updateUserProfile;
}

/// Creates UserProfile's production capabilities from app-owned services.
UserProfilePorts createUserProfilePorts(UserProfileDependencyReader read) =>
    createInternalUserProfilePorts(read);

/// Opaque dependencies requested by the UserProfile sync contribution.
enum UserProfileSyncDependency { database, firestore, remoteMutationExecutor }

DatasetSyncHandler createUserProfileDatasetSyncHandler(
  SyncDependencyReaderPort read, {
  required SyncHandlerRuntime runtime,
}) =>
    createInternalUserProfileDatasetSyncHandlerFacade(read, runtime: runtime);
