import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/application/coordinator/auth_user_coordinator.dart';
import 'package:my_dic/core/shared/enums/ui/button_status.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/auth_coordinator.dart';
import 'package:my_dic/features/auth/presentation/ui_model/sign_in_model.dart';

class SignInViewModel extends StateNotifier<SignInUIState> {
  final AppAuthCoordinator _authCoordinator;

  SignInViewModel(this._authCoordinator) : super(SignInUIState());

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
        print("**********signin success**********");
        state = state.copyWith(isWaitingSignIn: ButtonStatus.success);
        return 'ログインに成功しました';
      },
      failure: (error) async {
        state = state.copyWith(isWaitingSignIn: ButtonStatus.error);

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

        return 'アカウント作成に成功しました';
      },
      failure: (error) {
        state = state.copyWith(isWaitingSignUp: ButtonStatus.error);
        return error.message;
      },
    );
  }
}
