
abstract class ISyncStatusRepository {
  Future<DateTime?> getLastSyncDate();
  Future<void> updateSyncDate(DateTime date);

}