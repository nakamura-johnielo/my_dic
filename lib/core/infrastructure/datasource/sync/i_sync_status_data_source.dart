abstract class ISyncStatusDataSource {
  Future<DateTime?> getLastSyncDate();
  Future<void> updateSyncDate(DateTime date);
}
