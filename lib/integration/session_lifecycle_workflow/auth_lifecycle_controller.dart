import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/port/auth.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';
import 'auth_lifecycle_state.dart';

class AuthLifecycleController extends StateNotifier<AuthLifecycleState> {
  AuthLifecycleController({
    required AuthQueryPort query,
    required AuthCommandPort commands,
    required UserProfileCommandPort userProfileCommands,
  })  : _query = query,
        _commands = commands,
        _userProfileCommands = userProfileCommands,
        super(const AuthLifecycleState.initializing());

  final AuthQueryPort _query;
  final AuthCommandPort _commands;
  final UserProfileCommandPort _userProfileCommands;
  int _profileOperation = 0;

  Future<void> handleAuthStateChange(AuthIdentity? auth) async {
    if (auth == null) {
      _profileOperation++;
      state = const AuthLifecycleState(phase: AuthLifecyclePhase.signedOut);
      return;
    }
    if (!auth.emailVerified) {
      _profileOperation++;
      if (state.phase == AuthLifecyclePhase.creatingAccount ||
          state.phase == AuthLifecyclePhase.sendingVerificationEmail ||
          state.phase == AuthLifecyclePhase.verificationEmailFailed) return;
      state = AuthLifecycleState(
        phase: AuthLifecyclePhase.emailUnverified,
        auth: auth,
      );
      return;
    }
    await _provisionProfile(auth);
  }

  Future<void> signUp(String email, String password) async {
    if (state.isBusy) return;
    state = const AuthLifecycleState(phase: AuthLifecyclePhase.creatingAccount);
    final result = await _commands.signUp(
      SignUpCommand(email: email, password: password),
    );
    if (result case Success<AuthIdentity>(data: final auth)) {
      state = AuthLifecycleState(
        phase: AuthLifecyclePhase.sendingVerificationEmail,
        auth: auth,
      );
      await _sendVerification(auth);
      return;
    }
    state = AuthLifecycleState(
      phase: AuthLifecyclePhase.signedOut,
      error: result.errorOrNull!,
    );
  }

  Future<void> signIn(String email, String password) async {
    if (state.isBusy) return;
    state = const AuthLifecycleState(phase: AuthLifecyclePhase.signingIn);
    final result = await _commands.signIn(
      SignInCommand(email: email, password: password),
    );
    if (result case Success<AuthIdentity>(data: final auth)) {
      await handleAuthStateChange(auth);
      return;
    }
    state = AuthLifecycleState(
      phase: AuthLifecyclePhase.signedOut,
      error: result.errorOrNull!,
    );
  }

  Future<void> resendVerificationEmail() async {
    final auth = state.auth;
    if (auth == null || auth.emailVerified || state.isBusy) return;
    state = AuthLifecycleState(
      phase: AuthLifecyclePhase.sendingVerificationEmail,
      auth: auth,
    );
    await _sendVerification(auth);
  }

  Future<void> _sendVerification(AuthIdentity auth) async {
    final result = await _commands.sendVerificationEmail();
    if (result is Success<void>) {
      state = AuthLifecycleState(
        phase: AuthLifecyclePhase.emailUnverified,
        auth: auth,
        notice: 'Verification email sent. Please check your inbox.',
      );
      return;
    }
    state = AuthLifecycleState(
      phase: AuthLifecyclePhase.verificationEmailFailed,
      auth: auth,
      error: result.errorOrNull!,
    );
  }

  Future<void> checkEmailVerification() async {
    final auth = state.auth;
    if (auth == null || state.isBusy) return;
    state = AuthLifecycleState(
      phase: AuthLifecyclePhase.reloadingIdentity,
      auth: auth,
    );
    final result = await _query.reloadCurrentAuth();
    if (result case Success<AuthIdentity>(data: final refreshedAuth)) {
      await handleAuthStateChange(refreshedAuth);
      return;
    }
    state = AuthLifecycleState(
      phase: AuthLifecyclePhase.emailUnverified,
      auth: auth,
      error: result.errorOrNull!,
    );
  }

  Future<void> retryProfileProvisioning() async {
    final auth = state.auth;
    if (auth == null || !auth.emailVerified || state.isBusy) return;
    await _provisionProfile(auth);
  }

  Future<void> _provisionProfile(AuthIdentity auth) async {
    final operation = ++_profileOperation;
    state = AuthLifecycleState(
      phase: AuthLifecyclePhase.provisioningProfile,
      auth: auth,
    );
    final result = await _userProfileCommands.ensureUserProfile(
      auth.accountId,
      email: auth.email,
    );
    if (operation != _profileOperation ||
        state.auth?.accountId != auth.accountId) {
      return;
    }
    if (result case Success(data: final user)) {
      state = AuthLifecycleState(
        phase: AuthLifecyclePhase.ready,
        auth: auth,
        user: user,
      );
      return;
    }
    state = AuthLifecycleState(
      phase: AuthLifecyclePhase.profileProvisioningFailed,
      auth: auth,
      error: result.errorOrNull!,
    );
  }

  Future<void> signOut() async {
    if (state.isBusy) return;
    final previous = state;
    state = AuthLifecycleState(
      phase: AuthLifecyclePhase.signingOut,
      auth: previous.auth,
      user: previous.user,
    );
    final result = await _commands.signOut();
    if (result is Success<void>) {
      await handleAuthStateChange(null);
      return;
    }
    state = previous.copyWith(
      error: result.errorOrNull!,
      clearNotice: true,
    );
  }

  void reportUnexpected(Object error, StackTrace stackTrace) {
    state = state.copyWith(
      error: UnexpectedError(
        message: 'An unexpected error occurred. Please try again.',
        originalError: error,
        stackTrace: stackTrace,
      ),
      clearNotice: true,
    );
  }
}
