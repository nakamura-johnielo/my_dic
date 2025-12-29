import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/data/data_source/remote/user_profile_dao.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';
import 'i_user_remote_data_source.dart';

class FirebaseUserRemoteDataSource implements IUserRemoteDataSource {
  final UserDao _dao;
  FirebaseUserRemoteDataSource(this._dao);

  @override
  Future<AppUser?> getUserById(String id) async {
    final dto = await _dao.getUser(id);
    if (dto == null) return null;
    return AppUser(
      id: dto.userId,
      email: dto.email,
      username: dto.userName,
      subscriptionStatus: dto.subscriptionStatus,
    );
  }

  @override
  Future<void> updateUser(AppUser user) async {
    final dto = UserDTO(
      userId: user.id,
      email: user.email,
      userName: user.username,
      subscriptionStatus: user.subscriptionStatus,
      updatedAt: DateTime.now(),
    );
    await _dao.update(dto);
  }

  @override
  Future<void> createUser(AppUser user) async {
    final dto = UserDTO(
      userId: user.id,
      email: user.email,
      userName: user.username,
      subscriptionStatus: user.subscriptionStatus,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _dao.create(dto);
  }
}
