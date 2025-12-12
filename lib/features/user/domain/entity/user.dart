import 'package:my_dic/Constants/Enums/subscribe_status.dart';

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
}
