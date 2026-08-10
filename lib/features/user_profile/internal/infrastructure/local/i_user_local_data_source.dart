import 'package:my_dic/features/user_profile/internal/infrastructure/local/local_user_dto.dart';

abstract class IUserLocalDataSource {
  Future<LocalUserDTO?> getUser();

  Future<void> updateUser(LocalUserDTO user);

}
