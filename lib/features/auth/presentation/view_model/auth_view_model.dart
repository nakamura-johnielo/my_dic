import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/domain/usecase/signin.dart';
import 'package:my_dic/features/auth/domain/usecase/signout.dart';
import 'package:my_dic/features/auth/domain/usecase/signup.dart';
import 'package:my_dic/features/auth/domain/usecase/verify_email.dart';
import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/features/user/presentation/model/user_ui_model.dart';

class AuthViewModel extends StateNotifier<UserState?> {
  final SignInInteractor _signInInteractor;
  final SignUpInteractor _signUpInteractor;
  final VerifyEmailInteractor _verficateInteractor;
  final SignOutInteractor _signOutInteractor;

  AuthViewModel(this._signInInteractor, this._signUpInteractor,
      this._verficateInteractor, this._signOutInteractor)
      : super(null);

  void setAuthInfo(AppAuth appAuth) {
    state = state?.copyWith(
      id: appAuth.userId,
      email: appAuth.email,
      isAuthorized: appAuth.isVerified,
    );
  }

  // Future<void> signUp(String email, String password) async {
  //   await _signUpInteractor.execute(email, password);
  // }

  Future<void> signOut() async {
    await _signOutInteractor.execute();
  }

  Future<void> verifyEmail() async {
    await _verficateInteractor.execute();
  }

  Future<String> signIn(String email, String password) async {
    String message = "--";
    try {
      final authEntity = await _signInInteractor.execute(email, password);

      //final user = cred.user;
      if (authEntity != null) {
        // 新規 or 既存ユーザーのプロファイルドキュメントを用意
        // final user = AppUser(
        //     id: authEntity.userId,
        //     email: authEntity.email,
        //     username: email.split('@')[0],
        //     subscribeStatus: SubscribeStatus.trial);
        // await _updateUserInteractor.execute(user);

        if (!authEntity.isVerified) {
          await _verficateInteractor.execute();
          message = '確認メールを送信しました';
        } else {
          message = '成功しました';
        }
        if (!mounted) return message;
        // プロフィールページへ遷移（置き換え）
        //context.push('/${ScreenTab.profile}/${ScreenPage.authorized}');
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (_) => ProfilePage(uid: user.uid)),
        // );
        return message; // 以降のsetStateを避ける
      }
      return "登録に失敗しました";
    } catch (e) {
      message = '登録に失敗しました: $e';
      print(e);
    } finally {
      if (mounted) {
        message = "mounted " + message;
      }
      return message;
    }
  }

  Future<String> signUp(String email, String password) async {
    String message = "--";
    try {
      final authEntity = await _signUpInteractor.execute(email, password);

      //final user = cred.user;
      if (authEntity != null) {
        // 新規 or 既存ユーザーのプロファイルドキュメントを用意
        // final user = AppUser(
        //     id: authEntity.userId,
        //     email: authEntity.email,
        //     username: email.split('@')[0],
        //     subscribeStatus: SubscribeStatus.trial);
        // await _updateUserInteractor.execute(user);

        if (!authEntity.isVerified) {
          await _verficateInteractor.execute();
          message = '確認メールを送信しました';
        } else {
          message = '成功しました';
        }
        if (!mounted) return message;
        // プロフィールページへ遷移（置き換え）
        //context.push('/${ScreenTab.profile}/${ScreenPage.authorized}');
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (_) => ProfilePage(uid: user.uid)),
        // );
        return message; // 以降のsetStateを避ける
      }
      return "登録に失敗しました";
    } catch (e) {
      message = '登録に失敗しました: $e';
      print(e);
    } finally {
      if (mounted) {
        message = "mounted " + message;
      }
      return message;
    }
  }
}
