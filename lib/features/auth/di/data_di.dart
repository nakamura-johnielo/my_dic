import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/infrastructure/firebase/firebase_provider.dart';
import 'package:my_dic/features/auth/data/data_source/remote/firebase_auth_dao.dart';
import 'package:my_dic/features/auth/data/repository_impl/firebase_auth_repository_impl.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/domain/usecase/observe_auth_state_interactor.dart';
import 'package:my_dic/features/auth/domain/usecase/signin.dart';
import 'package:my_dic/features/auth/domain/usecase/signout.dart';
import 'package:my_dic/features/auth/domain/usecase/signup.dart';
import 'package:my_dic/features/auth/domain/usecase/verify_email.dart';

// firebase
// ====auth

//Dao
final authDaoProvider =
    Provider((ref) => FirebaseAuthDao(ref.read(firestoreAuthProvider)));

//repository
final firebaseAuthRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDao = ref.read(authDaoProvider);
  return FirebaseAuthRepositoryImpl(authDao);
});

//Usecase
final observeAuthStateUseCaseProvider = Provider(
  (ref) =>
      ObserveAuthStateInteractor(ref.watch(firebaseAuthRepositoryProvider)),
);

final signInInteractorProvider = Provider(
  (ref) => SignInInteractor(ref.watch(firebaseAuthRepositoryProvider)),
);

final signUpInteractorProvider = Provider(
  (ref) => SignUpInteractor(ref.watch(firebaseAuthRepositoryProvider)),
);

final signOutInteractorProvider = Provider(
  (ref) => SignOutInteractor(ref.watch(firebaseAuthRepositoryProvider)),
);

final verificateInteractorProvider = Provider(
  (ref) => VerifyEmailInteractor(ref.watch(firebaseAuthRepositoryProvider)),
);
