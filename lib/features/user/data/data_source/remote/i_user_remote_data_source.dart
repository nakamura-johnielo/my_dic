import 'package:my_dic/features/user/domain/entity/user.dart';

abstract class IUserRemoteDataSource {
  Future<AppUser?> getUserById(String id);

  Future<void> updateUser(AppUser user);

  Future<void> createUser(AppUser user);
}
