import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Constants/Enums/subscribe_status.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/DI/riverpod.dart';
import 'package:my_dic/_Business_Rule/Usecase/auth/observe_auth_state_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/auth/signin.dart';
import 'package:my_dic/_Business_Rule/Usecase/auth/signup.dart';
import 'package:my_dic/_Business_Rule/Usecase/auth/verficate.dart';
import 'package:my_dic/_Business_Rule/Usecase/user/user.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/user/app_auth.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/user/user.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_auth_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_user_repository.dart';
import 'package:my_dic/_View/UIModel/user_ui_model.dart';

final authStreamProvider = StreamProvider<AppAuth?>((ref) {
  final useCase = ref.read(observeAuthStateUseCaseProvider);
  return useCase.execute();
});

final userViewModelProvider =
    StateNotifierProvider<UserViewModel, UserUIModel?>((ref) {
  final getUserInteractor = ref.watch(getUserInteractorProvider);
  final signInInteractor = ref.watch(signInInteractorProvider);
  final signUpInteractor = ref.watch(signUpInteractorProvider);
  final updateUserInteractor = ref.watch(updateUserInteractorProvider);
  final verficateInteractor = ref.watch(verificateInteractorProvider);
  final signOutInteractor = ref.watch(signOutInteractorProvider);
  return UserViewModel(getUserInteractor, signInInteractor, signUpInteractor,
      updateUserInteractor, verficateInteractor, signOutInteractor);
});

class UserViewModel extends StateNotifier<UserUIModel?> {
  final GetUserInteractor _getUserInteractor;
  final SignInInteractor _signInInteractor;
  final SignUpInteractor _signUpInteractor;
  final UpdateUserInteractor _updateUserInteractor;
  final VerficateInteractor _verficateInteractor;
  final SignOutInteractor _signOutInteractor;

  UserViewModel(
      this._getUserInteractor,
      this._signInInteractor,
      this._signUpInteractor,
      this._updateUserInteractor,
      this._verficateInteractor,
      this._signOutInteractor)
      : super(null);

  Future<void> updateUser({String? name}) async {
    final user = AppUser(
        id: state?.id ?? "",
        email: state?.email,
        username: name ?? state?.username,
        subscribeStatus: state?.subscriptionStatus);
    await _updateUserInteractor.execute(user);
    state = UserUIModel.fromEntity(user,
        isLogined: state?.isLogined ?? false,
        isAuthorized: state?.isAuthorized ?? false);
  }

  Future<void> getUser(String id) async {
    final AppUser user = await _getUserInteractor.execute(id);
    state = UserUIModel.fromEntity(user,
        isLogined: state?.isLogined ?? false,
        isAuthorized: state?.isAuthorized ?? false);
  }

  void setAuthInfo(AppAuth appAuth) {
    state = state?.copyWith(
      id: appAuth.userId,
      email: appAuth.email,
      isAuthorized: appAuth.isVerified,
    );
  }

  Future<void> signUp(String email, String password) async {
    await _signUpInteractor.execute(email, password);
  }

  Future<void> signOut() async {
    await _signOutInteractor.execute();
  }

  // Future<void> signIn(String email, String password) async {
  //   await _signInInteractor.execute(email, password);
  // }

  Future<String> createUser(String email, String password) async {
    String message = "--";
    try {
      final authEntity = await _signUpInteractor.execute(email, password);

      //final user = cred.user;
      if (authEntity != null) {
        // 新規 or 既存ユーザーのプロファイルドキュメントを用意
        final user = AppUser(
            id: authEntity.userId,
            email: authEntity.email,
            username: email.split('@')[0],
            subscribeStatus: SubscriptionStatus.trial);
        await _updateUserInteractor.execute(user);

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
}
