import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as db;
import 'package:my_dic/core/infrastructure/database/shared_preferences/shared_preferences.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/drift_user_profile_dao.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/i_user_local_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/i_user_profile_local_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/shared_preferenced_user_dao.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/shared_preferenced_user_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_profile_drift_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_dao.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/i_user_remote_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/firebase_user_remote_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/user_repository.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/user_profile_provisioner.dart';
import 'package:my_dic/features/user_profile/internal/domain/i_repository/i_user_repository.dart';
import 'package:my_dic/features/user_profile/internal/domain/i_repository/i_user_profile_provisioner.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/firebase_dependencies.dart';
import 'package:my_dic/features/user_profile/port/composition.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';

final _legacyRemoteMutationExecutorProvider =
    Provider<RemoteMutationExecutor>((_) => throw StateError('Not composed'));
final _legacyOutboxWriterProvider =
    Provider<OutboxWriter>((_) => throw StateError('Not composed'));

final userDaoProvider = Provider((ref) => UserDao(
      ref.watch(userProfileFirestoreProvider),
      ref.watch(_legacyRemoteMutationExecutorProvider),
    ));

final userRemoteDataSourceProvider = Provider<IUserRemoteDataSource>(
    (ref) => FirebaseUserRemoteDataSource(ref.watch(userDaoProvider)));

final sharedPreferencesUserDaoProvider = Provider((ref) =>
    SharedPreferencesUserDao(
        ref.watch(sharedPreferencesProvider))); //TODO sharedpref

final userLocalDataSourceProvider = Provider<IUserLocalDataSource>((ref) =>
    SharedPreferencesUserDataSource(
        ref.watch(sharedPreferencesUserDaoProvider)));

final userProfileDaoProvider = Provider<UserProfileDao>(
    (ref) => UserProfileDao(ref.watch(databaseProvider)));

final userProfileLocalDataSourceProvider =
    Provider<IUserProfileLocalDataSource>(
        (ref) => UserProfileDriftDataSource(ref.watch(userProfileDaoProvider)));

/// Account-scoped live profile projection for presentation and session wiring.
final watchedUserProfileProvider = StreamProvider.autoDispose
    .family<db.UserProfile?, String>((ref, accountId) {
  return ref.watch(userProfileLocalDataSourceProvider).watchProfile(accountId);
});

/// App-facing repository: Drift reads and atomic Drift/outbox writes only.
final userRepositoryProvider = Provider<IUserRepository>((ref) {
  final local = ref.watch(userLocalDataSourceProvider);
  final profileLocal = ref.watch(userProfileLocalDataSourceProvider);
  final outboxWriter = ref.watch(_legacyOutboxWriterProvider);
  return UserRepository(local, profileLocal, outboxWriter);
});

/// Lifecycle adapter which may provision the remote baseline before the local
/// profile projection is used by the app.
final userProfileProvisionerProvider = Provider<IUserProfileProvisioner>((ref) {
  return UserProfileProvisioner(
    ref.watch(userRemoteDataSourceProvider),
    ref.watch(userLocalDataSourceProvider),
    ref.watch(userProfileLocalDataSourceProvider),
  );
});
