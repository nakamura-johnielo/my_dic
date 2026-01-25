import 'package:my_dic/core/shared/utils/result.dart';

abstract class ISyncRepository {
  Future<Result<void>> syncOnce(String userId);
  // Future<Result<void>> syncOnUpdatedLocal(String userId, String id);
  Future<Result<void>> syncOnUpdatedRemote(String userId, String id);

  Stream<List<int>> watchRemoteChangedIds(String userId);
}
