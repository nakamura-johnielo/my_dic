/// Auth IDに紐付く認証プロバイダー。
enum AuthProvider { google, apple, email, anonymous, unknown }

/// ビジネス利用側に公開する、Authが所有するID情報。
final class AuthIdentity {
  AuthIdentity({
    required this.accountId,
    this.emailVerified = false,
    AuthProvider? provider,
    this.email,
  }) : provider = provider ?? AuthProvider.anonymous;

  final String accountId;

  final AuthProvider provider;
  final String? email;
  final bool emailVerified;

  AuthIdentity copyWith({
    String? id,
    bool? emailVerified,
    AuthProvider? provider,
    String? email,
  }) =>
      AuthIdentity(
        accountId: id ?? accountId,
        emailVerified: emailVerified ?? this.emailVerified,
        provider: provider ?? this.provider,
        email: email ?? this.email,
      );
}
