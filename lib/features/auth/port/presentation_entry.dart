export 'package:my_dic/features/auth/internal/presentation/view/sign_up.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'app_auth.dart';

/// Feature-facing projection of the app-owned authentication workflow.
enum AuthPresentationPhase {
  initializing,
  signedOut,
  creatingAccount,
  signingIn,
  sendingVerificationEmail,
  emailUnverified,
  verificationEmailFailed,
  reloadingIdentity,
  provisioningProfile,
  profileProvisioningFailed,
  ready,
  signingOut,
}

final class AuthPresentationState {
  const AuthPresentationState({
    required this.phase,
    this.auth,
    this.error,
    this.notice,
  });

  final AuthPresentationPhase phase;
  final AppAuth? auth;
  final AppError? error;
  final String? notice;
}

abstract interface class AuthPresentationActions {
  Future<void> signUp(String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> resendVerificationEmail();
  Future<void> checkEmailVerification();
  Future<void> retryProfileProvisioning();
  Future<void> signOut();
}

/// The app composition root must provide this entry. Features never import
/// the app workflow that implements it.
final authPresentationStateProvider = Provider<AuthPresentationState>((ref) {
  throw UnsupportedError('Auth presentation entry is not installed.');
});

final authPresentationActionsProvider = Provider<AuthPresentationActions>((ref) {
  throw UnsupportedError('Auth presentation entry is not installed.');
});
