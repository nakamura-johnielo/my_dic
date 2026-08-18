/// The account boundary within which WordStatus reads and writes are made.
sealed class WordStatusScope {
  const WordStatusScope();

  const factory WordStatusScope.guest() = GuestWordStatusScope;

  factory WordStatusScope.account(String accountId) = AccountWordStatusScope;
}

/// The local unauthenticated WordStatus scope.
final class GuestWordStatusScope extends WordStatusScope {
  const GuestWordStatusScope();

  @override
  bool operator ==(Object other) => other is GuestWordStatusScope;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'WordStatusScope.guest()';
}

/// A WordStatus scope owned by one authenticated account identity.
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
