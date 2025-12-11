import 'package:my_dic/features/user/domain/entity/user.dart';

abstract class IUserRepository {
  Future<AppUser?> getUserById(String id);
  Future<void> updateUser(AppUser user);
}
