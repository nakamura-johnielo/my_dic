import 'package:my_dic/features/user/data/sync/remote/user_profile_dao.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'i_user_remote_data_source.dart';

class FirebaseUserRemoteDataSource implements IUserRemoteDataSource {
  final UserDao _dao;
  FirebaseUserRemoteDataSource(this._dao);

  @override
  Future<UserDTO?> getUserById(String id) async {
    return await _dao.getUser(id);
  }

  @override
  Future<void> updateUser(UserDTO user) async {
    await _dao.update(user);
  }

  @override
  Future<void> createUser(UserDTO user) async {
    await _dao.create(user);
  }

  @override
  Future<UserDTO> ensureUser(UserDTO user) => _dao.ensure(user);

  @override
  Future<RemoteMutationAck> patchUser(RemoteMutationRequest request) {
    return _dao.patch(request);
  }
}
