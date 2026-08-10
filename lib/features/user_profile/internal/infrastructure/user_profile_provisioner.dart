import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/utils/uuid.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/i_user_local_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/i_user_profile_local_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/i_user_remote_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/local_user_dto.dart';
import 'package:my_dic/features/user_profile/port/user_dto.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';
import 'package:my_dic/features/user_profile/internal/domain/i_repository/i_user_profile_provisioner.dart';

/// Remote provisioning adapter. It is the only user lifecycle path that uses
/// the remote user data source; routine profile reads and writes stay local.
class UserProfileProvisioner implements IUserProfileProvisioner {
  UserProfileProvisioner(this._remote, this._local, this._profileLocal);

  final IUserRemoteDataSource _remote;
  final IUserLocalDataSource _local;
  final IUserProfileLocalDataSource _profileLocal;

  Future<String> _getDeviceId() async {
    final existing = (await _local.getUser())?.deviceId;
    if (existing != null && existing.isNotEmpty) return existing;
    final created = MyUUID.generate();
    await _local.updateUser(LocalUserDTO(deviceId: created));
    return created;
  }

  @override
  Future<Result<AppUser>> ensureUserProfile({
    required String accountId,
    String? email,
  }) async {
    if (accountId.isEmpty) {
      return Result.failure(
        UnauthorizedError(message: 'Account ID cannot be empty. Must Login'),
      );
    }
    try {
      final deviceId = await _getDeviceId();
      final remoteProfile = await _remote.ensureUser(
        UserDTO(userId: accountId, email: email),
      );
      var username = await _profileLocal.getUsername(accountId);
      if (username == null) {
        await _profileLocal.applyRemoteFields(
          accountId,
          username: remoteProfile.userName,
        );
        username = remoteProfile.userName;
      }
      return Result.success(AppUser(
        deviceId: deviceId,
        email: remoteProfile.email ?? email,
        username: username,
        subscriptionStatus: remoteProfile.subscriptionStatus,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'User profile provisioning failed',
        originalError: e,
        stackTrace: s,
      ));
    }
  }
}
