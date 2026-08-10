import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

abstract class IUserRepository {
  Future<Result<AppUser>> getUserByAccountId(String id);
  Future<Result<void>> updateUser(AppUser user, String? accountId);
  Future<Result<void>> createNewUser(AppUser user, String? accountIds);
  Future<Result<String>> getThisDeviceId();
}
