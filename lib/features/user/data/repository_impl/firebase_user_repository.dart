import 'package:my_dic/Constants/Enums/subscribe_status.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';
import 'package:my_dic/features/user/data/data_source/remote/user_profile_dao.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';

class FirebaseUserRepository implements IUserRepository {
  final UserDao _userProfileDao;
  FirebaseUserRepository(this._userProfileDao);

  @override
  Future<AppUser?> getUserById(String id) async {
    final profileData = await _userProfileDao.getUser(id);
    return AppUser(
      id: id,
      email: profileData?.email,
      username: profileData?.userName,
      subscriptionStatus:
          profileData?.subscriptionStatus, // Default value or map accordingly
    );
  }

  @override
  Future<void> updateUser(AppUser user) async {
    final userEntity = UserDTO(
      userId: user.id,
      email: user.email ?? '',
      userName: user.username,
      subscriptionStatus:
          user.subscriptionStatus ?? SubscriptionStatus.free, // Default value
      //createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _userProfileDao.update(userEntity);
  }
}
