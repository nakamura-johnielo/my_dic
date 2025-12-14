import 'package:my_dic/core/common/enums/subscription_status.dart';

class AppUser {
  final String id;
  final String email;
  final String username;
  final SubscriptionStatus subscriptionStatus;

  AppUser({
    required this.id,
    String? email,
    String? username,
    SubscriptionStatus? subscriptionStatus,
  })  : email = email ?? '',
        username = username ?? 'Guest',
        subscriptionStatus = subscriptionStatus ?? SubscriptionStatus.free;

  AppUser copyWith({
    String? id,
    String? email,
    String? username,
    SubscriptionStatus? subscriptionStatus,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
    );
  }
}
