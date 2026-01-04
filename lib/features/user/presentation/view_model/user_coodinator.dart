import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/subscription_status.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/di/service.dart';
import 'package:my_dic/features/user/domain/usecase/i_create_new_user_use_case.dart';
import 'package:my_dic/features/user/domain/usecase/i_ensure_user_exists_use_case.dart';
import 'package:my_dic/features/user/domain/usecase/i_get_user_use_case.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/usecase/i_update_user_use_case.dart';
import 'package:my_dic/features/user/presentation/view_model/app_user_store.dart';

class AppUserCoordinator {
  final IGetUserUseCase _getUserInteractor;
  final IUpdateUserUseCase _updateUserInteractor;
  final IEnsureUserExistsUseCase _ensureUserExistsInteractor;
  final ICreateNewUserUseCase _createNewUserInteractor;
  final Ref ref;

  AppUser? get _userStore => ref.read(appUserStoreNotifierProvider);
  AppUserStoreNotifier get _storeNotifier =>
      ref.read(appUserStoreNotifierProvider.notifier);

  AppUserCoordinator(
      this._getUserInteractor,
      this._updateUserInteractor,
      this._ensureUserExistsInteractor,
      this._createNewUserInteractor,
      this.ref);

  Future<Result<void>> updateUser({
    //TOODO accountIdの供給法
    String? accountId,
    String? deviceId,
    String? email,
    String? username,
    SubscriptionStatus? subscriptionStatus,
  }) async {
    String? thisAccountId = accountId ?? _userStore?.accountId;
    if (thisAccountId == null) {
      log("アカウントIDが存在しません。");
      return Result.failure(UserNotFoundError(message: "アカウントIDが存在しません。"));
    }

    final user = _userStore?.copyWith(
            deviceId: deviceId,
            accountId: thisAccountId,
            email: email,
            username: username,
            subscriptionStatus: subscriptionStatus) ??
        AppUser(
            accountId: thisAccountId,
            deviceId: deviceId,
            email: email,
            username: username,
            subscriptionStatus: subscriptionStatus);

    final res = await _updateUserInteractor.execute(user);
    return res.map((_) => _storeNotifier.setUser(user));
  }

//TODO errorの時の再試行

  Future<Result<void>> createUser() async {
    if (_userStore == null) {
      log("accountIdがありません。");
      return Result.failure(
          UserNotFoundError(message: "ユーザー情報accountIdがありません"));
    }

    final res = await _createNewUserInteractor.execute(_userStore!.accountId);
    return res.map((user) {
      _storeNotifier.setUser(user);
    });
  }

  Future<Result<void>> refreshUser() async {
    if (_userStore == null) {
      log("accountIdがありません。");
      return Result.failure(UserNotFoundError(message: "ユーザー情報がありません"));
    }

    final res = await _getUserInteractor.execute(_userStore!.accountId);

    return res.when(success: (user) {
      _storeNotifier.setUser(user);
      return Result.success(null);
    }, failure: (error) {
      log("ユーザー情報の更新に失敗しました: ${error.message}");
      return Result.failure(error);
    });
  }
}
