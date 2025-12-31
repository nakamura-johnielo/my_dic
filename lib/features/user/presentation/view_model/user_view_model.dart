import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/subscription_status.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/domain/usecase/i_ensure_user_exists_use_case.dart';
import 'package:my_dic/features/user/domain/usecase/i_get_user_use_case.dart';
import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/presentation/model/user_ui_model.dart';
import 'package:my_dic/features/user/domain/usecase/i_update_user_use_case.dart';

class UserViewModel extends StateNotifier<UserState?> {
  final IGetUserUseCase _getUserInteractor;
  final IUpdateUserUseCase _updateUserInteractor;
  final IEnsureUserExistsUseCase _ensureUserExistsInteractor;

  UserViewModel(this._getUserInteractor, this._updateUserInteractor,
      this._ensureUserExistsInteractor)
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
    state = UserState.fromEntity(user,
        isLogined: state?.isLoggedIn ?? false,
        isAuthorized: state?.isAuthorized ?? false);
  }

  Future<void> createUser(AppUser user) async {
    await _updateUserInteractor.execute(user);
    state = UserState.fromEntity(user,
        isLogined: state?.isLoggedIn ?? false,
        isAuthorized: state?.isAuthorized ?? false);
  }

  Future<AppUser> loadUser(String id) async {
    final res = await _ensureUserExistsInteractor.execute(id);
    return res.when(success: (user) {
      state = UserState.fromEntity(user,
          isLogined: state?.isLoggedIn ?? false,
          isAuthorized: state?.isAuthorized ?? false);
      return user;
    }, failure: (error) {
      log("loaduserユーザー情報の取得に失敗しました: ${error.message}");
      return AppUser(id: id, username: "load fail");
      //throw Exception('ユーザー情報の取得に失敗しました: ${error.message}');
    });
    // final AppUser user = await _getUserInteractor.execute(id);
    // state = UserState.fromEntity(user,
    //     isLogined: state?.isLoggedIn ?? false,
    //     isAuthorized: state?.isAuthorized ?? false);
    //return user;
  }

  void setAuthInfo(AppAuth appAuth) {
    state = state?.copyWith(
      id: appAuth.userId,
      email: appAuth.email,
      isAuthorized: appAuth.isVerified,
    );
  }
}
