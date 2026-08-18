import 'package:flutter/material.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/features/auth/internal/presentation/view/sign_up.dart';
import 'command.dart';
import 'model/auth_identity.dart';

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
  final AuthIdentity? auth;
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

/// Controlled Flutter entry for Auth's email/password screen.
///
/// The app owns state observation and supplies the current projection plus
/// actions. No provider or override is part of this public surface.
class AuthPresentationPage extends StatelessWidget {
  const AuthPresentationPage({
    super.key,
    required this.state,
    required this.actions,
    required this.commands,
  });

  final AuthPresentationState state;
  final AuthPresentationActions actions;
  final AuthCommandPort commands;

  @override
  Widget build(BuildContext context) =>
      EmailPasswordPage(state: state, actions: actions, commands: commands);
}
