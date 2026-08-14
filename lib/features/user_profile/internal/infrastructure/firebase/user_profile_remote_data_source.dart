import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_remote_dto.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

abstract interface class UserProfileRemoteDataSource {
  Future<UserProfileRemoteDto?> getUserById(String id);

  Future<void> updateUser(UserProfileRemoteDto user);

  Future<void> createUser(UserProfileRemoteDto user);

  Future<UserProfileRemoteDto> ensureUser(UserProfileRemoteDto user);

  Future<RemoteMutationAck> patchUser(RemoteMutationRequest request);
}
