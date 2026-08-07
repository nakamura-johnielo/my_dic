import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_controller.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_state.dart';
import 'package:my_dic/features/auth/di/usecase_di.dart';
import 'package:my_dic/features/user/di/ensure_user_exists_di.dart';

final authLifecycleProvider =
    StateNotifierProvider<AuthLifecycleController, AuthLifecycleState>((ref) {
  return AuthLifecycleController(
    signIn: ref.watch(signInInteractorProvider),
    signUp: ref.watch(signUpInteractorProvider),
    signOut: ref.watch(signOutInteractorProvider),
    sendVerificationEmail: ref.watch(verificateInteractorProvider),
    reloadCurrentAuth: ref.watch(reloadCurrentAuthUseCaseProvider),
    ensureUserExists: ref.watch(ensureUserExistsInteractorProvider),
  );
});
