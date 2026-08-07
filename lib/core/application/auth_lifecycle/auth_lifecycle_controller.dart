import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_state.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/features/auth/application/usecase/auth_usecases.dart';
import 'package:my_dic/features/auth/application/usecase/i_sign_in_use_case.dart';
import 'package:my_dic/features/auth/presentation/view_model/auth_store.dart';
import 'package:my_dic/features/user/application/usecase/user_usecases.dart';
import 'package:my_dic/features/user/presentation/view_model/app_user_store.dart';

class AuthLifecycleController extends StateNotifier<AuthLifecycleState> {
  final ISignInUseCase _signIn;
  final ISignUpUseCase _signUp;
  final ISignOutUseCase _signOut;
  final IVerifyEmailUseCase _sendVerificationEmail;
  final IReloadCurrentAuthUseCase _reloadCurrentAuth;
  final IEnsureUserExistsUseCase _ensureUserExists;
  final AuthStoreNotifier _authStore;
  final AppUserStoreNotifier _userStore;

  int _profileOperation = 0;

  AuthLifecycleController({
    required ISignInUseCase signIn,
    required ISignUpUseCase signUp,
    required ISignOutUseCase signOut,
    required IVerifyEmailUseCase sendVerificationEmail,
    required IReloadCurrentAuthUseCase reloadCurrentAuth,
    required IEnsureUserExistsUseCase ensureUserExists,
    required AuthStoreNotifier authStore,
    required AppUserStoreNotifier userStore,
  })  : _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        _sendVerificationEmail = sendVerificationEmail,
        _reloadCurrentAuth = reloadCurrentAuth,
        _ensureUserExists = ensureUserExists,
        _authStore = authStore,
        _userStore = userStore,
        super(const AuthLifecycleState.initializing());

  Future<void> handleAuthStateChange(AppAuth? auth) async {
    if (auth == null) {
      _profileOperation++;
      _authStore.clear();
      _userStore.clear();
      state = const AuthLifecycleState(phase: AuthLifecyclePhase.signedOut);
      return;
    }

    _authStore.setAuth(auth);
    if (!auth.emailVerified) {
      _profileOperation++;
      _userStore.clear();
      if (state.phase == AuthLifecyclePhase.creatingAccount ||
          state.phase == AuthLifecyclePhase.sendingVerificationEmail ||
          state.phase == AuthLifecyclePhase.verificationEmailFailed) {
        return;
      }
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
    state = const AuthLifecycleState(
      phase: AuthLifecyclePhase.creatingAccount,
    );

    final result = await _signUp.execute(email, password);
    await result.when(
      success: (auth) async {
        _authStore.setAuth(auth);
        state = AuthLifecycleState(
          phase: AuthLifecyclePhase.sendingVerificationEmail,
          auth: auth,
        );
        await _sendVerification(auth);
      },
      failure: (error) async {
        state = AuthLifecycleState(
          phase: AuthLifecyclePhase.signedOut,
          error: error,
        );
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    if (state.isBusy) return;
    state = const AuthLifecycleState(phase: AuthLifecyclePhase.signingIn);

    final result = await _signIn.execute(email, password);
    await result.when(
      success: handleAuthStateChange,
      failure: (error) async {
        state = AuthLifecycleState(
          phase: AuthLifecyclePhase.signedOut,
          error: error,
        );
      },
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
    final result = await _sendVerificationEmail.execute();
    result.when(
      success: (_) {
        state = AuthLifecycleState(
          phase: AuthLifecyclePhase.emailUnverified,
          auth: auth,
          notice: '確認メールを送信しました。メール内のリンクを開いてください。',
        );
      },
      failure: (error) {
        state = AuthLifecycleState(
          phase: AuthLifecyclePhase.verificationEmailFailed,
          auth: auth,
          error: error,
        );
      },
    );
  }

  Future<void> checkEmailVerification() async {
    final auth = state.auth;
    if (auth == null || state.isBusy) return;
    state = AuthLifecycleState(
      phase: AuthLifecyclePhase.reloadingIdentity,
      auth: auth,
    );

    final result = await _reloadCurrentAuth.execute();
    await result.when(
      success: handleAuthStateChange,
      failure: (error) async {
        state = AuthLifecycleState(
          phase: AuthLifecyclePhase.emailUnverified,
          auth: auth,
          error: error,
        );
      },
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

    final result = await _ensureUserExists.execute(
      auth.accountId,
      email: auth.email,
    );
    if (operation != _profileOperation ||
        state.auth?.accountId != auth.accountId) {
      return;
    }

    result.when(
      success: (user) {
        _userStore.setUser(user);
        state = AuthLifecycleState(
          phase: AuthLifecyclePhase.ready,
          auth: auth,
          user: user,
        );
      },
      failure: (error) {
        _userStore.clear();
        state = AuthLifecycleState(
          phase: AuthLifecyclePhase.profileProvisioningFailed,
          auth: auth,
          error: error,
        );
      },
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

    final result = await _signOut.execute();
    await result.when(
      success: (_) => handleAuthStateChange(null),
      failure: (error) async {
        state = previous.copyWith(error: error, clearNotice: true);
      },
    );
  }

  void reportUnexpected(Object error, StackTrace stackTrace) {
    state = state.copyWith(
      error: UnexpectedError(
        message: '認証状態の更新中に予期しないエラーが発生しました',
        originalError: error,
        stackTrace: stackTrace,
      ),
      clearNotice: true,
    );
  }
}
