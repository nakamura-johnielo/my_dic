import 'package:my_dic/core/shared/consts/user/default.dart';
import 'package:my_dic/core/shared/enums/auth/subscription_status.dart';

/// UserProfile-owned values exposed to application workflows and UI.
///
/// Account identity remains owned by Auth and is therefore supplied to every
/// account-scoped operation instead of being embedded in this model.
class AppUser {
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
