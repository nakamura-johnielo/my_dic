import 'package:my_dic/core/shared/utils/result.dart';

abstract class ISyncUseCase {
  // syncpriority
  int get priority; //優先度。数値が小さいほど優先度高
  Future<Result<void>> syncOnce();
  Stream<List<int>> watchRemoteChangedIds();
  Future<Result<void>> syncOnUpdatedLocal(String id);
  Future<Result<void>> syncOnUpdatedRemote(String id);
}
