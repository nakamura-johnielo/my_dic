
```dart
abstract class ISyncUseCase {
  int get priority;//優先度。数値が小さいほど優先度高 SyncPriority
  Future<Result<void>> syncOnce(String userId);
  Stream<List<int>> watchRemoteChangedIds(String userId);
  Future<Result<void>> syncOnUpdatedLocal(String userId, String id);
  Future<Result<void>> syncOnUpdatedRemote(String userId, String id);
}

class Sync~Usecase implements ISyncUseCase {}
```

```dart
class SyncService{

}
```

SyncServiceにISyncUsecaseをリストでまとめて渡す
syncOnce, syncWithRemoteでまとめて呼び出す