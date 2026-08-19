/// WordStatus の読み書きを行うアカウント境界です。
sealed class WordStatusScope {
  const WordStatusScope();

  const factory WordStatusScope.guest() = GuestWordStatusScope;

  factory WordStatusScope.account(String accountId) = AccountWordStatusScope;
}

/// ローカルの未認証 WordStatus スコープです。
final class GuestWordStatusScope extends WordStatusScope {
  const GuestWordStatusScope();

  @override
  bool operator ==(Object other) => other is GuestWordStatusScope;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'WordStatusScope.guest()';
}

/// 1 つの認証済みアカウント識別子が所有する WordStatus スコープです。
final class AccountWordStatusScope extends WordStatusScope {
  factory AccountWordStatusScope(String accountId) {
    if (accountId.trim().isEmpty) {
      throw ArgumentError.value(accountId, 'accountId', 'must not be empty');
    }
    return AccountWordStatusScope._(accountId);
  }

  const AccountWordStatusScope._(this.accountId);

  final String accountId;

  @override
  bool operator ==(Object other) =>
      other is AccountWordStatusScope && other.accountId == accountId;

  @override
  int get hashCode => accountId.hashCode;

  @override
  String toString() => 'WordStatusScope.account(<redacted>)';
}
