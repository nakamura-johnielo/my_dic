import 'package:my_dic/core/shared/utils/result.dart';

abstract class ISyncEspJpnWordStatusUseCase {
  Future<Result<void>> syncOnce(String userId);
  Stream<List<int>> watchRemoteChangedIds(String userId);
  Stream<List<int>> watchLocalChangedIds();
  Future<Result<void>> syncOnUpdatedLocal(String userId,int wordId);
  Future<Result<void>> syncOnUpdatedRemote(String userId,int wordId);
}