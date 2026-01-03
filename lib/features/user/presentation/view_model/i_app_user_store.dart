import 'package:my_dic/core/shared/enums/subscription_status.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';

abstract class IAppUserStore {
  AppUser? get state;
  void updateUser({
    String? accountId,
    String? deviceId,
    String? email,
    String? username,
    SubscriptionStatus? subscriptionStatus,
  });

  void createdUser(AppUser user);
  // Future<AppUser> loadUser(String id);
}
