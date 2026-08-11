import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_dic/features/auth/internal/domain/repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/internal/infrastructure/firebase/firebase_auth_dao.dart';
import 'package:my_dic/features/auth/internal/infrastructure/firebase/firebase_auth_remote_data_source.dart';
import 'package:my_dic/features/auth/internal/infrastructure/firebase/firebase_auth_repository_impl.dart';

/// Canonical Firebase production adapter construction for Auth.
IAuthRepository createFirebaseAuthRepository() => AuthRepositoryImpl(
      FirebaseAuthRemoteDataSource(FirebaseAuthDao(FirebaseAuth.instance)),
    );
