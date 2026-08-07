import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/di/data_di.dart';
import 'package:my_dic/features/auth/application/usecase/auth_usecases.dart';
import 'package:my_dic/features/auth/application/usecase/i_sign_in_use_case.dart';
import 'package:my_dic/features/auth/application/usecase/signin.dart';

//Usecase
final observeAuthStateUseCaseProvider = Provider<IObserveAuthStateUseCase>(
  (ref) =>
      ObserveAuthStateInteractor(ref.watch(firebaseAuthRepositoryProvider)),
);

final reloadCurrentAuthUseCaseProvider = Provider<IReloadCurrentAuthUseCase>(
  (ref) => ReloadCurrentAuthInteractor(
    ref.watch(firebaseAuthRepositoryProvider),
  ),
);

final signInInteractorProvider = Provider<ISignInUseCase>(
  (ref) => SignInInteractor(ref.watch(firebaseAuthRepositoryProvider)),
);

final signUpInteractorProvider = Provider<ISignUpUseCase>(
  (ref) => SignUpInteractor(ref.watch(firebaseAuthRepositoryProvider)),
);

final signOutInteractorProvider = Provider<ISignOutUseCase>(
  (ref) => SignOutInteractor(ref.watch(firebaseAuthRepositoryProvider)),
);

final verificateInteractorProvider = Provider<IVerifyEmailUseCase>(
  (ref) => VerifyEmailInteractor(ref.watch(firebaseAuthRepositoryProvider)),
);

final resetEmailPasswordInteractorProvider =
    Provider<IResetEmailPasswordUseCase>(
  (ref) =>
      ResetEmailPasswordInteractor(ref.watch(firebaseAuthRepositoryProvider)),
);
