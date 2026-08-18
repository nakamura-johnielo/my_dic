/// The identity of one activated application data scope.
///
/// An account ID alone is deliberately insufficient: signing out and back in
/// as the same account must create a distinct scope so stale work cannot be
/// published into the new session.
final class SessionScopeKey {
  const SessionScopeKey({required this.accountScope, required this.epoch});

  final String accountScope;
  final int epoch;

  @override
  bool operator ==(Object other) =>
      other is SessionScopeKey &&
      other.accountScope == accountScope &&
      other.epoch == epoch;

  @override
  int get hashCode => Object.hash(accountScope, epoch);

  @override
  String toString() => 'SessionScopeKey($accountScope, $epoch)';
}
