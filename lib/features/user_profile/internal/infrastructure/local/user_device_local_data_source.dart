import 'package:my_dic/features/user_profile/internal/infrastructure/local/local_user_dto.dart';

abstract interface class UserDeviceLocalDataSource {
  Future<LocalUserDTO?> getUser();

  Future<void> updateUser(LocalUserDTO user);
}
