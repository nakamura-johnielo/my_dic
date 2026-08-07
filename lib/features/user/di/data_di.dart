import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as db;
import 'package:my_dic/core/infrastructure/database/firebase/firebase_provider.dart';
import 'package:my_dic/core/infrastructure/database/shared_preferences/shared_preferences.dart';
import 'package:my_dic/features/user/data/data_source/local/drift_user_profile_dao.dart';
import 'package:my_dic/features/user/data/data_source/local/i_user_local_data_source.dart';
import 'package:my_dic/features/user/data/data_source/local/i_user_profile_local_data_source.dart';
import 'package:my_dic/features/user/data/data_source/local/shared_preferenced_user_dao.dart';
import 'package:my_dic/features/user/data/data_source/local/shared_preferenced_user_data_source.dart';
import 'package:my_dic/features/user/data/data_source/local/user_profile_drift_data_source.dart';
import 'package:my_dic/features/user/data/data_source/remote/user_profile_dao.dart';
import 'package:my_dic/features/user/data/data_source/remote/i_user_remote_data_source.dart';
import 'package:my_dic/features/user/data/data_source/remote/firebase_user_remote_data_source.dart';
import 'package:my_dic/features/user/data/repository_impl/user_repository.dart';
import 'package:my_dic/features/user/data/sync/user_profile_sync_handler.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';

final userDaoProvider =
    Provider((ref) => UserDao(ref.watch(firestoreDBProvider)));

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

final firebaseUserRepositoryProvider = Provider<IUserRepository>((ref) {
  final remote = ref.watch(userRemoteDataSourceProvider);
  final local = ref.watch(userLocalDataSourceProvider);
  final profileLocal = ref.watch(userProfileLocalDataSourceProvider);
  final outboxWriter = ref.watch(driftOutboxWriterProvider);
  return UserRepository(remote, local, profileLocal, outboxWriter);
});

final userProfileSyncHandlerProvider = Provider<UserProfileSyncHandler>((ref) {
  return UserProfileSyncHandler(
    queue: ref.watch(driftSyncQueueProvider),
    executionGuard: ref.watch(syncExecutionGuardProvider),
    checkpointStore: ref.watch(driftSyncCheckpointStoreProvider),
    local: ref.watch(userProfileLocalDataSourceProvider),
    remote: ref.watch(userRemoteDataSourceProvider),
  );
});
