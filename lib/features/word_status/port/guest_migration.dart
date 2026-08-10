/// The guest-scoped row counts for the two dictionary directions.
final class WordStatusGuestRowCounts {
  const WordStatusGuestRowCounts({required this.espJpn, required this.jpnEsp});

  final int espJpn;
  final int jpnEsp;
}

/// App workflow capability for migrating guest dictionary-status rows.
abstract interface class WordStatusGuestMigration {
  Future<WordStatusGuestRowCounts> countGuestRows();

  Future<void> migrateGuestRows({
    required String accountId,
    required String migrationId,
    required DateTime Function() clock,
  });
}
