import 'package:my_dic/core/shared/enums/subscription_status.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';

class UserState {
  final String id;
  final String email;
  final String username;
  final SubscriptionStatus subscriptionStatus;
  final bool isLoggedIn;
  final bool isAuthorized;

  UserState({
    required this.id,
    required this.email,
    required this.username,
    required this.subscriptionStatus,
    this.isLoggedIn = false,
    this.isAuthorized = false,
  });

  static UserState fromEntity(AppUser user,
      {bool? isLogined, bool? isAuthorized}) {
    return UserState(
      id: user.id,
      email: user.email,
      username: user.username,
      subscriptionStatus: user.subscriptionStatus,
      isLoggedIn: isLogined ?? false,
      isAuthorized: isAuthorized ?? false,
    );
  }

  UserState copyWith({
    String? id,
    String? email,
    String? username,
    SubscriptionStatus? subscriptionStatus,
    bool? isLogined,
    bool? isAuthorized,
  }) {
    return UserState(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      isLoggedIn: isLogined ?? this.isLoggedIn,
      isAuthorized: isAuthorized ?? this.isAuthorized,
    );
  }
}
