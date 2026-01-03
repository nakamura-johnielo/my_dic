import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/subscription_status.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/presentation/view_model/i_app_user_store.dart';

class AppUserStoreNotifier extends StateNotifier<AppUser?>
    implements IAppUserStore {
  //TODO こっちが本物
  // final IGetUserUseCase _getUserInteractor;
  // final IUpdateUserUseCase _updateUserInteractor;
  // final IEnsureUserExistsUseCase _ensureUserExistsInteractor;

  AppUserStoreNotifier() : super(null);

  @override
  AppUser? get state => state;

  @override
  void updateUser({
    String? accountId,
    String? deviceId,
    String? email,
    String? username,
    SubscriptionStatus? subscriptionStatus,
  }) async {
    state = state?.copyWith(
        accountId: accountId,
        deviceId: deviceId,
        email: email,
        username: username,
        subscriptionStatus: subscriptionStatus);
  }

  @override
  Future<void> createdUser(AppUser user) async {
    state = user.copyWith();
  }
}
