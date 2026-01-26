import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/di/service.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/features/auth/domain/usecase/i_observe_auth_state_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_send_email_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_sign_in_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_sign_out_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_sign_up_use_case.dart';
import 'package:my_dic/features/auth/domain/usecase/i_verify_email_use_case.dart';
import 'package:my_dic/features/auth/presentation/view_model/auth_store.dart';

class AppAuthCoordinator {
  final Ref ref;

  final IObserveAuthStateUseCase _observeAuthStateUseCase;
  final IResetEmailPasswordUseCase _resetEmailPasswordUseCase;
  final ISignInUseCase _signInUseCase;
  final ISignUpUseCase _signUpUseCase;
  final ISignOutUseCase _signOutUseCase;
  final IVerifyEmailUseCase _verifyEmailUseCase;
  

  AppAuthCoordinator(
      this.ref,
      this._observeAuthStateUseCase,
      this._resetEmailPasswordUseCase,
      this._signInUseCase,
      this._signUpUseCase,
      this._signOutUseCase,
      this._verifyEmailUseCase);

  //AppAuth? get _authStore => ref.read(authStoreNotifierProvider);
  AuthStoreNotifier get _authStoreNotifier =>
      ref.read(authStoreNotifierProvider.notifier);

  // void setAuthInfo(AppAuth appAuth) {
  //   state = state?.copyWith(
  //     id: appAuth.userId,
  //     email: appAuth.email,
  //     isAuthorized: appAuth.isVerified,
  //   );
  // }


  Stream<AppAuth?> observeAuthState() => _observeAuthStateUseCase.execute();

  Future<Result<void>> signOut() async {
    final result = await _signOutUseCase.execute();
    return result.map((_) => _authStoreNotifier.signOut());
  }

  Future<Result<void>> verifyEmail() async {
    final result = await _verifyEmailUseCase.execute();
    return result;
  }

  Future<Result<void>> resetEmailPassword(String email) async {
    final result = await _resetEmailPasswordUseCase.execute(email);
    return result;
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
        _authStoreNotifier.setAuth(appAuth);
        return Result.success(appAuth);
      },
      failure: (error) {
        _authStoreNotifier.clear();
        return Result.failure(error);
      },
    );
  }

  Result<void> setAuth(AppAuth appAuth)  {
    try {
      _authStoreNotifier.setAuth(appAuth);
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnexpectedError(message: e.toString()));
    }
  }

  // Result<void> reloadAuth()  {
  //   try {
  //     _authStoreNotifier.setAuth(appAuth);
  //     return Result.success(null);
  //   } catch (e) {
  //     return Result.failure(UnexpectedError(message: e.toString()));
  //   }
  // }

  Future<Result<AppAuth>> signUp(String email, String password) async {
    final result = await _signUpUseCase.execute(email, password);

    return result.when(
      success: (appAuth) async {
        // if (!appAuth.isAuthenticated) {
        //   verifyEmail();
        //   // メール未確認でも認証情報は返す（確認メールは送信済み）
        // }
        _authStoreNotifier.setAuth(appAuth);
        return Result.success(appAuth);
      },
      failure: (error) {
        _authStoreNotifier.clear();
        return Result.failure(error);
      },
    );
  }
}
