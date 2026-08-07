import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/auth/subscription_status.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/di/service.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/user/application/usecase/user_usecases.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/presentation/view_model/app_user_store.dart';

class AppUserCoordinator {
  final IGetUserUseCase _getUserInteractor;
  final IUpdateUserUseCase _updateUserInteractor;
  final ICreateNewUserUseCase _createNewUserInteractor;
  final Ref ref;

  AppUser? get _userStore => ref.read(appUserStoreNotifierProvider);
  AppUserStoreNotifier get _storeNotifier =>
      ref.read(appUserStoreNotifierProvider.notifier);

  AppUserCoordinator(this._getUserInteractor, this._updateUserInteractor,
      this._createNewUserInteractor, this.ref);

  Future<Result<void>> updateUser({
    //TODO accountIdの供給法
    //  String? accountId,
    String? deviceId,
    String? email,
    String? username,
    SubscriptionStatus? subscriptionStatus,
  }) async {
    final user = _userStore?.copyWith(
            deviceId: deviceId,
            email: email,
            username: username,
            subscriptionStatus: subscriptionStatus) ??
        AppUser(
            deviceId: deviceId,
            email: email,
            username: username,
            subscriptionStatus: subscriptionStatus);

    final res = await _updateUserInteractor.execute(user);
    return res.map((_) => _storeNotifier.setUser(user));
  }

//TODO errorの時の再試行

  Future<Result<void>> createUser(AppUser appUser) async {
    final res = await _createNewUserInteractor.execute(appUser);
    return res.map((user) {
      AppLogger.print("AppUserCoordinator createUser user=${user.toString()}");
      _storeNotifier.setUser(user);
    });
  }

  Result<void> clear() {
    _storeNotifier.clear();
    return Result.success(null);
  }

  Future<Result<void>> refresh() async {
    final res = await _getUserInteractor.execute();

    return res.when(success: (user) {
      AppLogger.print("ユーザー情報をリフレッシュしました。${user.toString()}");
      _storeNotifier.setUser(user);
      return Result.success(null);
    }, failure: (error) async {
      AppLogger.print("ユーザー情報の更新に失敗しました: ${error.message}");

      return Result.failure(error);
    });
  }
}
