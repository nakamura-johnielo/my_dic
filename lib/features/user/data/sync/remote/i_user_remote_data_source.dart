import 'package:my_dic/features/user/data/dto/user_dto.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';

abstract class IUserRemoteDataSource {
  Future<UserDTO?> getUserById(String id);

  Future<void> updateUser(UserDTO user);

  Future<void> createUser(UserDTO user);

  Future<UserDTO> ensureUser(UserDTO user);

  Future<RemoteMutationAck> patchUser(RemoteMutationRequest request);
}
