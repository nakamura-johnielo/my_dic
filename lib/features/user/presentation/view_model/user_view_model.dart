import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/common/enums/subscription_status.dart';
// import 'package:my_dic/features/auth/domain/usecase/signin.dart';
// import 'package:my_dic/features/auth/domain/usecase/signout.dart';
// import 'package:my_dic/features/auth/domain/usecase/signup.dart';
// import 'package:my_dic/features/auth/domain/usecase/verify_email.dart';
import 'package:my_dic/features/user/domain/usecase/get_user.dart';
import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/_View/UIModel/user_ui_model.dart';
import 'package:my_dic/features/user/domain/usecase/update_user%20copy.dart';

class UserViewModel extends StateNotifier<UserUIModel?> {
  final GetUserInteractor _getUserInteractor;
  final UpdateUserInteractor _updateUserInteractor;
  //

  UserViewModel(this._getUserInteractor, this._updateUserInteractor)
      : super(null);

  Future<void> updateUser(
      {String? name,
      SubscriptionStatus? subscriptionStatus,
      String? email,
      String? id}) async {
    final user = AppUser(
        id: id ?? state?.id ?? "",
        email: email ?? state?.email,
        username: name ?? state?.username,
        subscriptionStatus: subscriptionStatus ?? state?.subscriptionStatus);
    await _updateUserInteractor.execute(user);
    state = UserUIModel.fromEntity(user,
        isLogined: state?.isLoggedIn ?? false,
        isAuthorized: state?.isAuthorized ?? false);
  }

  Future<void> createUser(AppUser user) async {
    await _updateUserInteractor.execute(user);
    state = UserUIModel.fromEntity(user,
        isLogined: state?.isLoggedIn ?? false,
        isAuthorized: state?.isAuthorized ?? false);
  }

  Future<AppUser> loadUser(String id) async {
    final AppUser user = await _getUserInteractor.execute(id);
    state = UserUIModel.fromEntity(user,
        isLogined: state?.isLoggedIn ?? false,
        isAuthorized: state?.isAuthorized ?? false);
    return user;
  }

  void setAuthInfo(AppAuth appAuth) {
    state = state?.copyWith(
      id: appAuth.userId,
      email: appAuth.email,
      isAuthorized: appAuth.isVerified,
    );
  }
}
