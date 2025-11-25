import 'package:my_dic/Constants/Enums/subscribe_status.dart';

class AppUser {
  final String id;
  final String email;
  final String username;
  final SubscriptionStatus subscribeStatus;

  AppUser({
    required this.id,
    String? email,
    String? username,
    SubscriptionStatus? subscribeStatus,
  })  : email = email ?? '',
        username = username ?? 'Guest',
        subscribeStatus = subscribeStatus ?? SubscriptionStatus.free;
}
