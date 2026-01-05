import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';

abstract class IUserRepository {
  // Future<Result<AppUser>> getUser(String id);
  Future<Result<AppUser>> getUserByAccountId(String id);
  Future<Result<void>> updateUser(AppUser user);
  Future<Result<void>> createNewUser(AppUser user);
  Future<Result<String>> getThisDeviceId();
}
