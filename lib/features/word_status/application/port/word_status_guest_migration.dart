/// The guest-scoped row counts for the two dictionary directions.
///
/// Keeping this result direction-specific lets the app preserve its existing
/// guest-data prompt without learning about local row types or sync datasets.
class WordStatusGuestRowCounts {
  const WordStatusGuestRowCounts({
    required this.espJpn,
    required this.jpnEsp,
  });

  final int espJpn;
  final int jpnEsp;
}

/// Migrates WordStatus rows from the guest scope into a signed-in account.
///
/// The caller owns the outer transaction and session fence because this
/// capability participates in the larger cross-feature guest migration.
abstract interface class WordStatusGuestMigration {
  Future<WordStatusGuestRowCounts> countGuestRows();

  Future<void> migrateGuestRows({
    required String accountId,
    required String migrationId,
    required DateTime Function() clock,
  });
}
