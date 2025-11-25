import 'package:my_dic/Constants/Enums/subscribe_status.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/user/user.dart';

class UserUIModel {
  final String id;
  final String email;
  final String username;
  final SubscriptionStatus subscriptionStatus;
  final bool isLogined;
  final bool isAuthorized;

  UserUIModel({
    required this.id,
    required this.email,
    required this.username,
    required this.subscriptionStatus,
    this.isLogined = false,
    this.isAuthorized = false,
  });

  static UserUIModel fromEntity(AppUser user,
      {bool? isLogined, bool? isAuthorized}) {
    return UserUIModel(
      id: user.id,
      email: user.email,
      username: user.username,
      subscriptionStatus: user.subscribeStatus,
      isLogined: isLogined ?? false,
      isAuthorized: isAuthorized ?? false,
    );
  }

  UserUIModel copyWith({
    String? id,
    String? email,
    String? username,
    SubscriptionStatus? subscriptionStatus,
    bool? isLogined,
    bool? isAuthorized,
  }) {
    return UserUIModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      isLogined: isLogined ?? this.isLogined,
      isAuthorized: isAuthorized ?? this.isAuthorized,
    );
  }
}
