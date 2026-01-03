enum ProviderType { google, apple, email, anonymous,unknown }

extension ProviderTypeExtension on ProviderType {
  static ProviderType fromFirebaseProviderId(String? providerId) {
    switch (providerId) {
      case 'google.com':
        return ProviderType.google;
      case 'apple.com':
        return ProviderType.apple;
      case 'password':
        return ProviderType.email;
      case "anonymous":
        return ProviderType.anonymous;
      default:
        return ProviderType.unknown; // 未対応のプロバイダIDの場合
    }
  }
}
