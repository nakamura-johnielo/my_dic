import 'package:my_dic/features/user/data/dto/user_dto.dart';

abstract class IUserRemoteDataSource {
  Future<UserDTO?> getUserById(String id);

  Future<void> updateUser(UserDTO user);

  Future<void> createUser(UserDTO user);
}
