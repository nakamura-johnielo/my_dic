enum SubscriptionStatus { free, premium, trial }

extension SubscribeStatusExtension on SubscriptionStatus {
  String get label {
    switch (this) {
      case SubscriptionStatus.free:
        return '無料プラン';
      case SubscriptionStatus.premium:
        return 'Premium';
      case SubscriptionStatus.trial:
        return 'Free Trial';
    }
  }

  String get subscriptionCode {
    switch (this) {
      case SubscriptionStatus.free:
        return '100';
      case SubscriptionStatus.trial:
        return '101';
      case SubscriptionStatus.premium:
        return '300';
    }
  }
}
