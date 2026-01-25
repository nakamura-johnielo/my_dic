import 'package:my_dic/core/shared/utils/result.dart';

abstract class ISyncMyWordUseCase {
  Future<Result<void>> syncOnce();

  Stream<List<int>> watchRemoteChangedIds();

  Stream<List<int>> watchLocalChangedIds();

  Future<Result<void>> syncOnUpdatedLocal(int wordId);

  Future<Result<void>> syncOnUpdatedRemote(int wordId);
}
