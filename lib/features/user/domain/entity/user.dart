import 'package:my_dic/core/shared/consts/user/default.dart';
import 'package:my_dic/core/shared/enums/subscription_status.dart';

class AppUser {
  // accountIdはデバイスに対して１つ
  //provider等から割り当てられるやつ
  //acountIdはAuth確認には使わない！！！
  final String accountId;
  final String? deviceId;
  final String? email;
  final String username;
  final SubscriptionStatus subscriptionStatus;

  AppUser({
    required this.accountId,
     this.deviceId,
    this.email,
    String? username,
    SubscriptionStatus? subscriptionStatus,
  })  : username = username ?? UserConsts.username,
        subscriptionStatus = subscriptionStatus ?? UserConsts.subscriptionStatus;

  AppUser copyWith({
    String? accountId,
    String? deviceId,
    String? email,
    String? username,
    SubscriptionStatus? subscriptionStatus,
  }) {
    return AppUser(
      accountId: accountId ?? this.accountId,
      deviceId: deviceId ?? this.deviceId,
      email: email ?? this.email,
      username: username ?? this.username,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
    );
  }
}
