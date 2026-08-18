/// The guest-scoped rows owned by the MyWord aggregate.
final class MyWordGuestRowCounts {
  const MyWordGuestRowCounts({required this.words, required this.statuses});

  final int words;
  final int statuses;
}

/// App-workflow seam for migrating the entire MyWord aggregate.
///
/// Transactions, session fencing, and coordination with other features remain
/// owned by the app. Implementations own the MyWord row and status-row policy.
abstract interface class MyWordGuestMigrationPort {
  Future<MyWordGuestRowCounts> countGuestRows();

  Future<void> migrateGuestRows({
    required String accountId,
    required String migrationId,
    required DateTime Function() clock,
  });
}
