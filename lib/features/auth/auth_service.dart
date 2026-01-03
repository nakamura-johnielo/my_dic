import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/features/auth/domain/usecase/i_observe_auth_state_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_send_email_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_sign_in_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_sign_out_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_sign_up_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_verify_email_use_case.dart';
import 'package:my_dic/features/auth/presentation/view_model/i_auth_store.dart';

class AuthService {
  final IAuthStore _authStore;

  final IObserveAuthStateUseCase _observeAuthStateUseCase;
  final IResetEmailPasswordUseCase _resetEmailPasswordUseCase;
  final ISignInUseCase _signInUseCase;
  final ISignUpUseCase _signUpUseCase;
  final ISignOutUseCase _signOutUseCase;
  final IVerifyEmailUseCase _verifyEmailUseCase;

  AuthService(
      {required IAuthStore authStore,
      required IObserveAuthStateUseCase observeAuthStateUseCase,
      required IResetEmailPasswordUseCase resetEmailPasswordUseCase,
      required ISignInUseCase signInUseCase,
      required ISignUpUseCase signUpUseCase,
      required ISignOutUseCase signOutUseCase,
      required IVerifyEmailUseCase verifyEmailUseCase})
      : _authStore = authStore,
        _observeAuthStateUseCase = observeAuthStateUseCase,
        _resetEmailPasswordUseCase = resetEmailPasswordUseCase,
        _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _verifyEmailUseCase = verifyEmailUseCase;

  // void setAuthInfo(AppAuth appAuth) {
  //   state = state?.copyWith(
  //     id: appAuth.userId,
  //     email: appAuth.email,
  //     isAuthorized: appAuth.isVerified,
  //   );
  // }

  Future<Result<void>> signOut() async {
    final result = await _signOutUseCase.execute();
    return result.map((_) => _authStore.signOut());
  }

  Future<Result<void>> verifyEmail() async {
    final result = await _verifyEmailUseCase.execute();
    return result.map((_) => _authStore.sendVerifyEmail());
  }

  Future<Result<void>> resetEmailPassword(String email) async {
    final result = await _resetEmailPasswordUseCase.execute(email);
    return result.map((_) => _authStore.sendResetEmailPassword());
  }

  Future<Result<AppAuth>> signIn(String email, String password) async {
    final result = await _signInUseCase.execute(email, password);

    return result.when(
      success: (appAuth) async {
        // if (!appAuth.isAuthenticated) {
        //   verifyEmail();
        //   // メール未確認でも認証情報は返す（確認メールは送信済み）
        // }
        print("**********signin success**********");
        _authStore.update(appAuth);
        return Result.success(appAuth);
      },
      failure: (error) {
        _authStore.clear();
        return Result.failure(error);
      },
    );
  }

  Future<Result<AppAuth>> signUp(String email, String password) async {
    final result = await _signUpUseCase.execute(email, password);

    return result.when(
      success: (appAuth) async {
        // if (!appAuth.isAuthenticated) {
        //   verifyEmail();
        //   // メール未確認でも認証情報は返す（確認メールは送信済み）
        // }
        _authStore.update(appAuth);
        return Result.success(appAuth);
      },
      failure: (error) {
        _authStore.clear();
        return Result.failure(error);
      },
    );
  }
}
