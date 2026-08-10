import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/internal/di/usecase_di.dart';

import 'auth_commands.dart';
import 'auth_readers.dart';

/// Public, framework-free dependency bundle for the app session workflow.
final class AuthLifecyclePorts {
  const AuthLifecyclePorts({
    required this.observeAuthState,
    required this.reloadCurrentAuth,
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.sendVerificationEmail,
  });

  final ObserveAuthStatePort observeAuthState;
  final ReloadCurrentAuthPort reloadCurrentAuth;
  final SignInPort signIn;
  final SignUpPort signUp;
  final SignOutPort signOut;
  final SendVerificationEmailPort sendVerificationEmail;
}

/// Public composition entry for app-owned lifecycle orchestration.
final authLifecyclePortsProvider = Provider<AuthLifecyclePorts>((ref) {
  return AuthLifecyclePorts(
    observeAuthState: ref.watch(observeAuthStateUseCaseProvider),
    reloadCurrentAuth: ref.watch(reloadCurrentAuthUseCaseProvider),
    signIn: ref.watch(signInInteractorProvider),
    signUp: ref.watch(signUpInteractorProvider),
    signOut: ref.watch(signOutInteractorProvider),
    sendVerificationEmail: ref.watch(verificateInteractorProvider),
  );
});
