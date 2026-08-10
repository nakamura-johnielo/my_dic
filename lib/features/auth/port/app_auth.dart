import 'package:my_dic/core/shared/enums/auth/provider_type.dart';

class AppAuth {
  // accountIdはaccountに対して１つ
  //provider等から割り当てられるやつ
  final String accountId;
  final bool isLogined;
  final bool isAuthenticated;
  final ProviderType provider;
  final String? email;

  /// Firebase が保持するメール確認済みフラグ。
  ///
  /// `isAuthenticated` は既存呼び出しとの互換性のため残すが、新規コードでは
  /// 事実を表すこの名前を使用する。
  bool get emailVerified => isAuthenticated;

  AppAuth({
    required this.accountId,
    bool? isLogined,
    bool? isAuthenticated,
    ProviderType? provider,
    this.email,
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
      accountId: id ?? accountId,
      isLogined: isLogined ?? this.isLogined,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      provider: provider ?? this.provider,
      email: email ?? this.email,
    );
  }
}
