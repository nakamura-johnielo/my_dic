import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/port/app_auth.dart';
import 'package:my_dic/features/auth/port/composition.dart';
import 'package:my_dic/features/auth/port/auth_commands.dart';
import 'package:my_dic/features/auth/port/auth_readers.dart';
import 'package:my_dic/features/user_profile/port/composition.dart';
import 'package:my_dic/features/user_profile/port/auth_lifecycle.dart';
import 'auth_lifecycle_state.dart';

class AuthLifecycleController extends StateNotifier<AuthLifecycleState> {
  AuthLifecycleController({
    AuthLifecyclePorts? auth,
    UserLifecyclePorts? user,
    SignInPort? signIn,
    SignUpPort? signUp,
    SignOutPort? signOut,
    SendVerificationEmailPort? sendVerificationEmail,
    ReloadCurrentAuthPort? reloadCurrentAuth,
    EnsureUserProfilePort? ensureUserExists,
  })  : assert(
          (auth != null && user != null) ||
              (signIn != null &&
                  signUp != null &&
                  signOut != null &&
                  sendVerificationEmail != null &&
                  reloadCurrentAuth != null &&
                  ensureUserExists != null),
        ),
        _auth = auth ?? AuthLifecyclePorts(
          // Tests and transitional callers may provide lifecycle capabilities
          // individually; production composition always supplies one bundle.
          observeAuthState: _NoAuthObserver(),
          reloadCurrentAuth: reloadCurrentAuth!,
          signIn: signIn!,
          signUp: signUp!,
          signOut: signOut!,
          sendVerificationEmail: sendVerificationEmail!,
        ),
        _user = user ?? UserLifecyclePorts(
          ensureUserProfile: ensureUserExists!,
        ),
        super(const AuthLifecycleState.initializing());

  final AuthLifecyclePorts _auth;
  final UserLifecyclePorts _user;
  int _profileOperation = 0;

  Future<void> handleAuthStateChange(AppAuth? auth) async {
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
    final result = await _auth.signUp.signUp(email, password);
    await result.when(
      success: (auth) async {
        state = AuthLifecycleState(
          phase: AuthLifecyclePhase.sendingVerificationEmail,
          auth: auth,
        );
        await _sendVerification(auth);
      },
      failure: (error) async => state = AuthLifecycleState(
        phase: AuthLifecyclePhase.signedOut,
        error: error,
      ),
    );
  }

  Future<void> signIn(String email, String password) async {
    if (state.isBusy) return;
    state = const AuthLifecycleState(phase: AuthLifecyclePhase.signingIn);
    final result = await _auth.signIn.signIn(email, password);
    await result.when(
      success: handleAuthStateChange,
      failure: (error) async => state = AuthLifecycleState(
        phase: AuthLifecyclePhase.signedOut,
        error: error,
      ),
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

  Future<void> _sendVerification(AppAuth auth) async {
    final result = await _auth.sendVerificationEmail.sendVerificationEmail();
    result.when(
      success: (_) => state = AuthLifecycleState(
        phase: AuthLifecyclePhase.emailUnverified,
        auth: auth,
        notice: 'Verification email sent. Please check your inbox.',
      ),
      failure: (error) => state = AuthLifecycleState(
        phase: AuthLifecyclePhase.verificationEmailFailed,
        auth: auth,
        error: error,
      ),
    );
  }

  Future<void> checkEmailVerification() async {
    final auth = state.auth;
    if (auth == null || state.isBusy) return;
    state = AuthLifecycleState(
      phase: AuthLifecyclePhase.reloadingIdentity,
      auth: auth,
    );
    final result = await _auth.reloadCurrentAuth.reloadCurrentAuth();
    await result.when(
      success: handleAuthStateChange,
      failure: (error) async => state = AuthLifecycleState(
        phase: AuthLifecyclePhase.emailUnverified,
        auth: auth,
        error: error,
      ),
    );
  }

  Future<void> retryProfileProvisioning() async {
    final auth = state.auth;
    if (auth == null || !auth.emailVerified || state.isBusy) return;
    await _provisionProfile(auth);
  }

  Future<void> _provisionProfile(AppAuth auth) async {
    final operation = ++_profileOperation;
    state = AuthLifecycleState(
      phase: AuthLifecyclePhase.provisioningProfile,
      auth: auth,
    );
    final result = await _user.ensureUserProfile.ensureUserProfile(
      auth.accountId,
      email: auth.email,
    );
    if (operation != _profileOperation || state.auth?.accountId != auth.accountId) {
      return;
    }
    result.when(
      success: (user) => state = AuthLifecycleState(
        phase: AuthLifecyclePhase.ready,
        auth: auth,
        user: user,
      ),
      failure: (error) => state = AuthLifecycleState(
        phase: AuthLifecyclePhase.profileProvisioningFailed,
        auth: auth,
        error: error,
      ),
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
    final result = await _auth.signOut.signOut();
    await result.when(
      success: (_) => handleAuthStateChange(null),
      failure: (error) async => state = previous.copyWith(
        error: error,
        clearNotice: true,
      ),
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

final class _NoAuthObserver implements ObserveAuthStatePort {
  @override
  Stream<AppAuth?> observeAuthState() => const Stream.empty();
}
