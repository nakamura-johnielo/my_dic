import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/internal/infrastructure/firebase/firebase_auth_dependencies.dart';
import 'package:my_dic/features/auth/internal/domain/repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/internal/infrastructure/firebase/firebase_auth_dao.dart';
import 'package:my_dic/features/auth/internal/infrastructure/firebase/firebase_auth_remote_data_source.dart';
import 'package:my_dic/features/auth/internal/infrastructure/firebase/firebase_auth_repository_impl.dart';
import 'package:my_dic/features/auth/internal/infrastructure/firebase/i_auth_remote_data_source.dart';

// firebase
// ====auth

//Dao
final authDaoProvider =
    Provider((ref) => FirebaseAuthDao(ref.read(authFirebaseAuthProvider)));

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
