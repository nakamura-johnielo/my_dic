import 'package:my_dic/Constants/Enums/subscribe_status.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_user_repository.dart';
import 'package:my_dic/_Framework_Driver/remote/firebase/DAO/user_profile_dao.dart';
import 'package:my_dic/_Framework_Driver/remote/firebase/Entity/userEntity.dart';

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
    final userEntity = UserEntity(
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
