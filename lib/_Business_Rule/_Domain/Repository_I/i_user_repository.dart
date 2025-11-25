import 'package:my_dic/_Business_Rule/_Domain/Entities/user/user.dart';

abstract class IUserRepository {
  Future<AppUser?> getUserById(String id);
  Future<void> updateUser(AppUser user);
}
