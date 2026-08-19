/// Ranking がステータス情報を読み取る際に使用するアカウント境界。
sealed class RankingAccountScope {
  const RankingAccountScope();

  const factory RankingAccountScope.guest() = GuestRankingAccountScope;

  factory RankingAccountScope.account(String accountId) =
      AccountRankingScope;
}

final class GuestRankingAccountScope extends RankingAccountScope {
  const GuestRankingAccountScope();

  @override
  bool operator ==(Object other) => other is GuestRankingAccountScope;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class AccountRankingScope extends RankingAccountScope {
  factory AccountRankingScope(String accountId) {
    if (accountId.trim().isEmpty) {
      throw ArgumentError.value(accountId, 'accountId', 'must not be empty');
    }
    return AccountRankingScope._(accountId);
  }

  const AccountRankingScope._(this.accountId);

  final String accountId;

  @override
  bool operator ==(Object other) =>
      other is AccountRankingScope && other.accountId == accountId;

  @override
  int get hashCode => accountId.hashCode;

  @override
  String toString() => 'RankingAccountScope.account(<redacted>)';
}
