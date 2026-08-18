/// Authentication provider attached to an Auth identity.
enum AuthProvider { google, apple, email, anonymous, unknown }

/// Auth-owned identity facts exposed to business consumers.
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
