
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/auth/subscription_status.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';

class AppUserStoreNotifier extends StateNotifier<AppUser?>
     {

  AppUserStoreNotifier() : super(null);

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

  
  void setUser(AppUser user) async {
    state = user.copyWith();
  }

  void clear() async {
    state = null;
  }
}
