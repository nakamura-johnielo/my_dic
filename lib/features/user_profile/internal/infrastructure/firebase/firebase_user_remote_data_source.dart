import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/firebase_user_profile_dao.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_remote_dto.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'user_profile_remote_data_source.dart';

final class FirebaseUserRemoteDataSource implements UserProfileRemoteDataSource {
  final FirebaseUserProfileDao _dao;
  FirebaseUserRemoteDataSource(this._dao);

  @override
  Future<UserProfileRemoteDto?> getUserById(String id) async {
    return await _dao.getUser(id);
  }

  @override
  Future<void> updateUser(UserProfileRemoteDto user) async {
    await _dao.update(user);
  }

  @override
  Future<void> createUser(UserProfileRemoteDto user) async {
    await _dao.create(user);
  }

  @override
  Future<UserProfileRemoteDto> ensureUser(UserProfileRemoteDto user) =>
      _dao.ensure(user);

  @override
  Future<RemoteMutationAck> patchUser(RemoteMutationRequest request) {
    return _dao.patch(request);
  }
}
