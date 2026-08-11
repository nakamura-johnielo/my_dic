import 'package:my_dic/core/shared/consts/user/default.dart';
import 'package:my_dic/core/shared/enums/auth/subscription_status.dart';
import 'package:my_dic/core/shared/utils/result.dart';

class AppUser {
  // accountIdはaccountに対して１つ
  //provider等から割り当てられるやつ
  //acountIdはAuth確認には使わない！！！
  // final String accountId;
  final String? deviceId;
  final String? email;
  final String username;
  final SubscriptionStatus subscriptionStatus;

  AppUser({
    this.deviceId,
    this.email,
    String? username,
    SubscriptionStatus? subscriptionStatus,
  })  : username = username ?? UserConsts.username,
        subscriptionStatus =
            subscriptionStatus ?? UserConsts.subscriptionStatus;

  AppUser copyWith({
    String? deviceId,
    String? email,
    String? username,
    SubscriptionStatus? subscriptionStatus,
  }) {
    return AppUser(
      deviceId: deviceId ?? this.deviceId,
      email: email ?? this.email,
      username: username ?? this.username,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
    );
  }
}

/// Profile mutation capability used by the controlled presentation entry.
abstract interface class UpdateUserProfilePort {
  Future<Result<void>> updateUser(AppUser user, String accountId);
}
