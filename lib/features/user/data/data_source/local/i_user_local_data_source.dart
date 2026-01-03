import 'package:my_dic/features/user/data/dto/local_user_dto.dart';

abstract class IUserLocalDataSource {
  Future<LocalUserDTO?> getUser();

  Future<void> updateUser(LocalUserDTO user);

}
