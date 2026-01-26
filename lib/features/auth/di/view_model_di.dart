import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/coordinator/corrdinator.dart';
import 'package:my_dic/features/auth/auth_coordinator.dart';
import 'package:my_dic/features/auth/di/service.dart';
import 'package:my_dic/features/auth/di/usecase_di.dart';
import 'package:my_dic/features/auth/domain/usecase/send_email_interactor.dart';
import 'package:my_dic/features/auth/presentation/ui_model/sign_in_model.dart';
import 'package:my_dic/features/auth/presentation/view_model/sign_in_view_model.dart';

// final authViewModelProvider =
//     StateNotifierProvider<AuthViewModel, UserState?>((ref) {
//   final signInInteractor = ref.watch(signInInteractorProvider);
//   final signUpInteractor = ref.watch(signUpInteractorProvider);
//   final verficateInteractor = ref.watch(verificateInteractorProvider);
//   final signOutInteractor = ref.watch(signOutInteractorProvider);
//   final resetEmailPasswordInteractor =
//       ref.watch(resetEmailPasswordInteractorProvider);
//   return AuthViewModel(signInInteractor, signUpInteractor, verficateInteractor,
//       signOutInteractor,resetEmailPasswordInteractor);
// });

final authCoordinatorProvider=Provider<AppAuthCoordinator>((ref){
  final observeAuthStateUseCase=ref.watch(observeAuthStateUseCaseProvider);
  final resetEmailPasswordUseCase=ref.watch(resetEmailPasswordInteractorProvider);
  final signInUseCase=ref.watch(signInInteractorProvider);
  final signUpUseCase=ref.watch(signUpInteractorProvider);
  final signOutUseCase=ref.watch(signOutInteractorProvider);
  final verifyEmailUseCase=ref.watch(verificateInteractorProvider);

  return AppAuthCoordinator(
    ref,
    observeAuthStateUseCase,
    resetEmailPasswordUseCase,
    signInUseCase,
    signUpUseCase,
    signOutUseCase,
    verifyEmailUseCase,
  );
});

final signInViewModelProvider=StateNotifierProvider<SignInViewModel, SignInUIState>((ref) {
  final authCoordinator=ref.watch(authCoordinatorProvider);
//  final authUserCoordinator=ref.watch(authUserCoordinatorProvider);
  return SignInViewModel(authCoordinator);
});