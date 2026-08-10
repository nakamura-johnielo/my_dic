import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/sync/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_sync_composition_factory.dart';
import 'package:my_dic/features/user_profile/internal/di/data_di.dart';
import 'package:my_dic/features/user_profile/internal/di/ensure_user_exists_di.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/live_user_profile_adapter.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/user_profile_guest_migration_adapter.dart';
import 'auth_lifecycle.dart';
import 'guest_migration.dart';
import 'live_user_profile.dart';

/// App composition supplies SDK-owning mutation and persistence services.
final userProfileRemoteMutationExecutorDependencyProvider =
    Provider<RemoteMutationExecutor>((_) => throw StateError(
        'RemoteMutationExecutor dependency was not supplied.'));
final userProfileOutboxWriterDependencyProvider = Provider<OutboxWriter>(
  (_) => throw StateError('OutboxWriter dependency was not supplied.'),
);


/// Public dependency bundle for app-owned session lifecycle orchestration.
final class UserLifecyclePorts {
  const UserLifecyclePorts({required this.ensureUserProfile});

  final EnsureUserProfilePort ensureUserProfile;
}

/// Public assembly entry for the app session workflow. The implementation
/// graph remains feature-internal; callers consume only [UserLifecyclePorts].
final userLifecyclePortsProvider = Provider<UserLifecyclePorts>((ref) =>
    UserLifecyclePorts(
      ensureUserProfile: ref.watch(ensureUserExistsInteractorProvider),
    ));

final userProfileGuestMigrationPortProvider =
    Provider<UserProfileGuestMigrationPort>((ref) =>
        UserProfileGuestMigrationAdapter(
          ref.watch(userProfileLocalDataSourceProvider),
        ));

final liveUserProfilePortProvider = Provider<LiveUserProfilePort>((ref) =>
    LiveUserProfileAdapter(ref.watch(userProfileLocalDataSourceProvider)));

final liveUserProfileProvider =
    StreamProvider.autoDispose.family((ref, String accountId) =>
        ref.watch(liveUserProfilePortProvider).watchProfile(accountId));

/// Opaque dependencies requested by the UserProfile sync contribution.
enum UserProfileSyncDependency { database, firestore, remoteMutationExecutor }

DatasetSyncHandler createUserProfileDatasetSyncHandler(
  SyncDependencyReader read, {
  required SyncHandlerRuntime runtime,
}) => createInternalUserProfileDatasetSyncHandler(read, runtime: runtime);
