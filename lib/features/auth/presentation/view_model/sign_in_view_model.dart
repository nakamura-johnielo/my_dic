import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/application/coordinator/auth_user_coordinator.dart';
import 'package:my_dic/core/shared/enums/ui/button_status.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/auth_coordinator.dart';
import 'package:my_dic/features/auth/presentation/ui_model/sign_in_model.dart';

class SignInViewModel extends StateNotifier<SignInUIState> {
  // final ISignInUseCase _signInInteractor;
  // final ISignUpUseCase _signUpInteractor;
  // final IVerifyEmailUseCase _verficateInteractor;
  // final ISignOutUseCase _signOutInteractor;
  // final IResetEmailPasswordUseCase _resetEPasswordUseCase;
  // final AuthService _authService;
  final AppAuthCoordinator _authCoordinator;

  SignInViewModel(this._authCoordinator)
      : super(SignInUIState());

  Future<String> signOut() async {
    state = state.copyWith(isWaitingSignOut: ButtonStatus.waiting);

    final result = await _authCoordinator.signOut();

    return result.when(
      success: (_) {
        state = state.copyWith(isWaitingSignOut: ButtonStatus.success);

        return 'ログアウトしました';
      },
      failure: (error) {
        state = state.copyWith(isWaitingSignOut: ButtonStatus.error);
        return 'ログアウトに失敗しました: ${error.message}';
      },
    );
  }

  // Future<String> verifyEmail() async {
  //   print("verifyEmail in VM===================");
  //   state = state.copyWith(isWaitingVerifyEmail: ButtonStatus.waiting);
  //   final result = await _authCoordinator.verifyEmail();
  //   return result.when(
  //     success: (_) {
  //       state = state.copyWith(isWaitingVerifyEmail: ButtonStatus.success);
  //       return '確認メールを送信しました';
  //     },
  //     failure: (error) {
  //       state = state.copyWith(isWaitingVerifyEmail: ButtonStatus.error);
  //       return '送信に失敗しました: ${error.message}';
  //     },
  //   );
  // }

  Future<String> resetEmailPassword(String email) async {
    state = state.copyWith(isWaitingResetPassword: ButtonStatus.waiting);
    final result = await _authCoordinator.resetEmailPassword(email);
    return result.when(
      success: (_) {
        state = state.copyWith(isWaitingResetPassword: ButtonStatus.success);
        return 'リセット用メールを送信しました';
      },
      failure: (error) {
        state = state.copyWith(isWaitingResetPassword: ButtonStatus.error);
        return '送信に失敗しました: ${error.message}';
      },
    );
  }

  Future<String> signIn(String email, String password) async {
    state = state.copyWith(isWaitingSignIn: ButtonStatus.waiting);
    final result = await _authCoordinator.signIn(email, password);

    return result.when(
      success: (appAuth) async {
        // if (!appAuth.isAuthenticated) {
        //   verifyEmail();
        //   // メール未確認でも認証情報は返す（確認メールは送信済み）
        // }
        print("**********signin success**********");
        state = state.copyWith(isWaitingSignIn: ButtonStatus.success);
        return 'ログインに成功しました';
      },
      failure: (error) async {
        state = state.copyWith(isWaitingSignIn: ButtonStatus.error);
        //   if (error is DeviceNotFoundError ||
        //     error is UserNotFoundError ||
        //     error is NotFoundError) {
        //       print("**********signin create user**********");
        //   final resu= await _authUserCoordinator.createUser();
        // }
        return error.message;
      },
    );
  }

  Future<String> signUp(String email, String password) async {
    state = state.copyWith(isWaitingSignUp: ButtonStatus.waiting);
    final result = await _authCoordinator.signUp(email, password);

    return result.when(
      success: (appAuth) async {
        print("##########################signUP success");
        state = state.copyWith(isWaitingSignUp: ButtonStatus.success);

        // if (!appAuth.isAuthenticated) {
        //   verifyEmail();
        //   // メール未確認でも認証情報は返す（確認メールは送信済み）
        // }
        return 'アカウント作成に成功しました';
      },
      failure: (error) {
        // if(error is UnauthorizedError){
        //   verifyEmail();

        // }
        state = state.copyWith(isWaitingSignUp: ButtonStatus.error);
        return error.message;
      },
    );
  }
}
