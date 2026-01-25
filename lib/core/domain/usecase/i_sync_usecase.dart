import 'package:my_dic/core/shared/utils/result.dart';

abstract class ISyncUseCase {
  // syncpriority
  int get priority;//優先度。数値が小さいほど優先度高
  Future<Result<void>> syncOnce(String userId);
  Stream<List<int>> watchRemoteChangedIds(String userId);
  Future<Result<void>> syncOnUpdatedLocal(String userId, String id);
  Future<Result<void>> syncOnUpdatedRemote(String userId, String id);
}
