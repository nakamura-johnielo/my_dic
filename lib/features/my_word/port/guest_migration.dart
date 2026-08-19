/// MyWord 集約が所有するゲストスコープの行。
final class MyWordGuestRowCounts {
  const MyWordGuestRowCounts({required this.words, required this.statuses});

  final int words;
  final int statuses;
}

/// MyWord 集約全体を移行するためのアプリワークフロー境界。
///
/// トランザクション、セッションフェンシング、他機能との調整はアプリが所有したままとする。
/// 実装は MyWord 行とステータス行のポリシーを所有する。
abstract interface class MyWordGuestMigrationPort {
  Future<MyWordGuestRowCounts> countGuestRows();

  Future<void> migrateGuestRows({
    required String accountId,
    required String migrationId,
    required DateTime Function() clock,
  });
}
