import 'package:my_dic/features/auth/port/auth.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

enum AuthLifecyclePhase {
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

class AuthLifecycleState {
  final AuthLifecyclePhase phase;
  final AuthIdentity? auth;
  final AppUser? user;
  final AppError? error;
  final String? notice;

  const AuthLifecycleState({
    required this.phase,
    this.auth,
    this.user,
    this.error,
    this.notice,
  });

  const AuthLifecycleState.initializing()
      : this(phase: AuthLifecyclePhase.initializing);

  bool get isReady => phase == AuthLifecyclePhase.ready;

  bool get isBusy => switch (phase) {
        AuthLifecyclePhase.creatingAccount ||
        AuthLifecyclePhase.signingIn ||
        AuthLifecyclePhase.sendingVerificationEmail ||
        AuthLifecyclePhase.reloadingIdentity ||
        AuthLifecyclePhase.provisioningProfile ||
        AuthLifecyclePhase.signingOut =>
          true,
        _ => false,
      };

  bool get needsEmailVerification => switch (phase) {
        AuthLifecyclePhase.sendingVerificationEmail ||
        AuthLifecyclePhase.emailUnverified ||
        AuthLifecyclePhase.verificationEmailFailed ||
        AuthLifecyclePhase.reloadingIdentity =>
          true,
        _ => false,
      };

  AuthLifecycleState copyWith({
    AuthLifecyclePhase? phase,
    AuthIdentity? auth,
    AppUser? user,
    AppError? error,
    String? notice,
    bool clearError = false,
    bool clearNotice = false,
  }) =>
      AuthLifecycleState(
        phase: phase ?? this.phase,
        auth: auth ?? this.auth,
        user: user ?? this.user,
        error: clearError ? null : error ?? this.error,
        notice: clearNotice ? null : notice ?? this.notice,
      );
}
