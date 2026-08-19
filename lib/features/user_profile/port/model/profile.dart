import 'package:my_dic/core/shared/consts/user/default.dart';
import 'package:my_dic/core/shared/enums/auth/subscription_status.dart';

/// アプリケーションワークフローと UI に公開する UserProfile 所有の値です。
///
/// アカウント識別子は引き続き Auth が所有します。そのためこのモデルに埋め込まず、
/// すべてのアカウントスコープ操作へ渡します。
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
