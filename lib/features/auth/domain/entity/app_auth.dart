import 'package:my_dic/core/shared/enums/auth/provider_type.dart';

class AppAuth {
  // accountIdはアカウントに対して１つ
  //provider等から割り当てられるやつ
  final String accountId;
  final bool isLogined;
  final bool isAuthenticated;
  final ProviderType provider;
  final String? email;

  AppAuth({
    required this.accountId,
    bool? isLogined,
    bool? isAuthenticated,
    ProviderType? provider, this.email,
  })  : isLogined = isLogined ?? false,
        isAuthenticated = isAuthenticated ?? false,
        provider = provider ?? ProviderType.anonymous;

  AppAuth copyWith({
    String? id,
    bool? isLogined,
    bool? isAuthenticated,
    ProviderType? provider,
    String? email,
  }) {
    return AppAuth(
      accountId: id ?? this.accountId,
      isLogined: isLogined ?? this.isLogined,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      provider: provider ?? this.provider,
      email: email ?? this.email,
    );
  }
}
