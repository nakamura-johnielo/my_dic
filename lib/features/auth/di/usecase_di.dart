import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/di/data_di.dart';
import 'package:my_dic/features/auth/domain/usecase/i_observe_auth_state_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_sign_in_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_sign_out_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_sign_up_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_verify_email_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/observe_auth_state_interactor.dart';
import 'package:my_dic/features/auth/domain/usecase/signin.dart';
import 'package:my_dic/features/auth/domain/usecase/signout.dart';
import 'package:my_dic/features/auth/domain/usecase/signup.dart';
import 'package:my_dic/features/auth/domain/usecase/verify_email.dart';



//Usecase
final observeAuthStateUseCaseProvider = Provider<IObserveAuthStateUseCase>(
  (ref) =>
      ObserveAuthStateInteractor(ref.watch(firebaseAuthRepositoryProvider)),
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
