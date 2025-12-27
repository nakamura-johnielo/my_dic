abstract class ISyncEspJpnWordStatusUseCase {
  //TODO RESULT
  // Future<DateTime?> getLastSyncDate(String key);
  Future<void> syncOnce(String userId);
  Stream<List<int>> watchRemoteChangedIds(String userId);
  Stream<List<int>> watchLocalChangedIds();
  Future<void> syncOnUpdatedLocal(String userId,int wordId);
  Future<void> syncOnUpdatedRemote(String userId,int wordId);
}