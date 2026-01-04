import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/infrastructure/database/firebase/firebase_provider.dart';
import 'package:my_dic/core/infrastructure/database/shared_preferences/shared_preferences.dart';
import 'package:my_dic/features/user/data/data_source/local/i_user_local_data_source.dart';
import 'package:my_dic/features/user/data/data_source/local/shared_preferenced_user_dao.dart';
import 'package:my_dic/features/user/data/data_source/local/shared_preferenced_user_data_source.dart';
import 'package:my_dic/features/user/data/data_source/remote/user_profile_dao.dart';
import 'package:my_dic/features/user/data/data_source/remote/i_user_remote_data_source.dart';
import 'package:my_dic/features/user/data/data_source/remote/firebase_user_remote_data_source.dart';
import 'package:my_dic/features/user/data/repository_impl/user_repository.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';

final userDaoProvider =
    Provider((ref) => UserDao(ref.watch(firestoreDBProvider)));

final userRemoteDataSourceProvider =
  Provider<IUserRemoteDataSource>((ref) =>
    FirebaseUserRemoteDataSource(ref.watch(userDaoProvider)));

final sharedPreferencesUserDaoProvider =
    Provider((ref) => SharedPreferencesUserDao(ref.watch(sharedPreferencesProvider)));//TODO sharedpref

final userLocalDataSourceProvider =
  Provider<IUserLocalDataSource>((ref) =>
    SharedPreferencesUserDataSource(ref.watch(sharedPreferencesUserDaoProvider)));

final firebaseUserRepositoryProvider = Provider<IUserRepository>((ref) {
  final remote = ref.watch(userRemoteDataSourceProvider);
  final local=ref.watch(userLocalDataSourceProvider);
  return UserRepository(remote,local);
});
