import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/auth_coordinator.dart';
import 'package:my_dic/features/auth/di/usecase_di.dart';
import 'package:my_dic/features/auth/presentation/ui_model/sign_in_model.dart';
import 'package:my_dic/features/auth/presentation/view_model/sign_in_view_model.dart';

final authCoordinatorProvider = Provider<AppAuthCoordinator>((ref) {
  final observeAuthStateUseCase = ref.watch(observeAuthStateUseCaseProvider);
  final resetEmailPasswordUseCase =
      ref.watch(resetEmailPasswordInteractorProvider);
  final signInUseCase = ref.watch(signInInteractorProvider);
  final signUpUseCase = ref.watch(signUpInteractorProvider);
  final signOutUseCase = ref.watch(signOutInteractorProvider);
  final verifyEmailUseCase = ref.watch(verificateInteractorProvider);

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

final signInViewModelProvider =
    StateNotifierProvider<SignInViewModel, SignInUIState>((ref) {
  final authCoordinator = ref.watch(authCoordinatorProvider);
  return SignInViewModel(authCoordinator);
});
