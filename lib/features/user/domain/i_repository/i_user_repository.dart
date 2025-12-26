import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';

abstract class IUserRepository {
  Future<Result<AppUser>> getUserById(String id);
  Future<Result<void>> updateUser(AppUser user);
}
