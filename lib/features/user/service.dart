import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/subscription_status.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/domain/usecase/i_create_new_user_use_case.dart';
import 'package:my_dic/features/user/domain/usecase/i_ensure_user_exists_use_case.dart';
import 'package:my_dic/features/user/domain/usecase/i_get_user_use_case.dart';
import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/usecase/i_update_user_use_case.dart';
import 'package:my_dic/features/user/presentation/view_model/i_app_user_store.dart';

class UserService {
  //TODO こっちが本物
  final IGetUserUseCase _getUserInteractor;
  final IUpdateUserUseCase _updateUserInteractor;
  final IEnsureUserExistsUseCase _ensureUserExistsInteractor;
  final ICreateNewUserUseCase _createNewUserInteractor;
  final IAppUserStore _appUserStore;

  UserService(
      this._getUserInteractor,
      this._updateUserInteractor,
      this._ensureUserExistsInteractor,
      this._createNewUserInteractor,
      this._appUserStore);

  Future<Result<void>> updateUser({//TOODO accountIdの供給法
    required String accountId,
    String? deviceId,
    String? email,
    String? username,
    SubscriptionStatus? subscriptionStatus,
  }) async {
    final user = AppUser(
        deviceId: deviceId,
        accountId: accountId,
        email: email,
        username: username,
        subscriptionStatus: subscriptionStatus);

    final res = await _updateUserInteractor.execute(user);
   return  res.map((_) => _appUserStore.updateUser(
        accountId: accountId,
        deviceId: deviceId,
        email: email,
        username: username,
        subscriptionStatus: subscriptionStatus));
  }

//TODO errorの時の再試行

  Future<Result<void>> createUser(AppUser user) async {
    final res = await _createNewUserInteractor.execute(user);
    return res.map((_) {
      _appUserStore.createdUser(user);
    });
  }

  Future<Result<void>> loadUser(String accountId) async {
    final res = await _getUserInteractor.execute(accountId);
    return res.map((user) {
      _appUserStore.updateUser(
          accountId: accountId,
          deviceId: user.deviceId,
          email: user.email,
          username: user.username,
          subscriptionStatus: user.subscriptionStatus);
    });
    // final AppUser user = await _getUserInteractor.execute(id);
    // state = UserState.fromEntity(user,
    //     isLogined: state?.isLoggedIn ?? false,
    //     isAuthorized: state?.isAuthorized ?? false);
    //return user;
  }
}
