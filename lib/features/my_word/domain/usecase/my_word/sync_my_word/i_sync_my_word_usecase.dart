import 'package:my_dic/core/shared/utils/result.dart';

abstract class ISyncMyWordUseCase {
  Future<Result<void>> syncOnce();

  Stream<List<String>> watchRemoteChangedIds();

  Stream<List<String>> watchLocalChangedIds();

  Future<Result<void>> syncOnUpdatedLocal(String wordId);

  Future<Result<void>> syncOnUpdatedRemote(String wordId);
}
