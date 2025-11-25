import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/Usecase/auth/observe_auth_state_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/auth/signin.dart';
import 'package:my_dic/_Business_Rule/Usecase/auth/signup.dart';
import 'package:my_dic/_Business_Rule/Usecase/auth/verficate.dart';
import 'package:my_dic/_Business_Rule/Usecase/user/user.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_auth_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_user_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_word_status_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/firebase_auth_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/firebase_user_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/wordstatus_repository.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/word_status_dao.dart';
import 'package:my_dic/_Framework_Driver/remote/firebase/DAO/user_profile_dao.dart';
import 'package:my_dic/_Framework_Driver/remote/firebase/DAO/auth.dart';
import 'package:my_dic/_Framework_Driver/remote/firebase/DAO/word_status_dao.dart';
import 'package:my_dic/_Framework_Driver/remote/firebase/base.dart';

// firebase
// ====auth
//Dao
final authDaoProvider =
    Provider((ref) => FirebaseAuthDao(ref.watch(firestoreAuthProvider)));
//repository
final firebaseAuthRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDao = ref.watch(authDaoProvider);
  return FirebaseAuthRepository(authDao);
});

// ====data
//Dao
final userDaoProvider =
    Provider((ref) => UserDao(ref.watch(firestoreDBProvider)));

final remoteWordStatusDaoProvider =
    Provider((ref) => FirebaseWordStatusDao(ref.watch(firestoreDBProvider)));

// repository
final firebaseUserRepositoryProvider = Provider<IUserRepository>((ref) {
  final dataSource = ref.watch(userDaoProvider);
  return FirebaseUserRepository(dataSource);
});

final firebaseWordStatusRepositoryProvider =
    Provider<IWordStatusRepository>((ref) {
  final local = ref.read(localWordStatusDaoProvider);
  final remote = ref.read(remoteWordStatusDaoProvider);
  // final localDataSource = ref.watch(localWordStatusDaoProvider);
  // return WordStatusRepository(dataSource, localDataSource);
  return WordStatusRepository(remote, local);
});

//====================================================----
//==================================================
// UseCase
final observeAuthStateUseCaseProvider = Provider(
  (ref) => ObserveAuthStateInteractor(ref.watch(firebaseAuthRepositoryProvider),
      ref.watch(firebaseUserRepositoryProvider)),
);

final getUserInteractorProvider = Provider(
  (ref) => GetUserInteractor(ref.watch(firebaseUserRepositoryProvider)),
);

final signInInteractorProvider = Provider(
  (ref) => SignInInteractor(ref.watch(firebaseAuthRepositoryProvider)),
);

final signUpInteractorProvider = Provider(
  (ref) => SignUpInteractor(ref.watch(firebaseAuthRepositoryProvider)),
);

final updateUserInteractorProvider = Provider(
  (ref) => UpdateUserInteractor(ref.watch(firebaseUserRepositoryProvider)),
);

final verificateInteractorProvider = Provider(
  (ref) => VerficateInteractor(ref.watch(firebaseAuthRepositoryProvider)),
);

final signOutInteractorProvider = Provider(
  (ref) => SignOutInteractor(ref.watch(firebaseAuthRepositoryProvider)),
);
