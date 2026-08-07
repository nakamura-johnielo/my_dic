import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/firebase_providers.dart';
import 'package:my_dic/features/auth/data/data_source/remote/firebase_auth_dao.dart';
import 'package:my_dic/features/auth/data/data_source/remote/firebase_auth_remote_data_source.dart';
import 'package:my_dic/features/auth/data/data_source/remote/i_auth_remote_data_source.dart';
import 'package:my_dic/features/auth/data/repository_impl/firebase_auth_repository_impl.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';

// firebase
// ====auth

//Dao
final authDaoProvider =
    Provider((ref) => FirebaseAuthDao(ref.read(firestoreAuthProvider)));

// DataSource
final authDataSourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  final dao = ref.read(authDaoProvider);
  return FirebaseAuthRemoteDataSource(dao);
});

//repository
final firebaseAuthRepositoryProvider = Provider<IAuthRepository>((ref) {
  final ds = ref.read(authDataSourceProvider);
  return AuthRepositoryImpl(ds);
});
