/// 有効化されたアプリケーションデータスコープ1件の識別子。
///
/// アカウントIDだけでは意図的に不十分です。同じアカウントでサインアウト後に再サインインした
/// 場合も別のスコープを作成し、古い処理が新しいセッションへ反映されないようにします。
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
