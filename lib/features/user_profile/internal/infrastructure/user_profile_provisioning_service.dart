import 'package:my_dic/core/shared/utils/uuid.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_device_local_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_profile_local_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_remote_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_remote_dto.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/local_user_dto.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';
import 'package:my_dic/features/user_profile/internal/domain/service/user_profile_provisioning_port.dart';

/// リモートプロビジョニングアダプターです。リモートユーザーデータソースを使用する唯一の
/// ユーザーライフサイクル経路であり、通常のプロフィール読み書きはローカルに留まります。
final class UserProfileProvisioningService
    implements UserProfileProvisioningPort {
  UserProfileProvisioningService(
    this._remote,
    this._local,
    this._profileLocal,
  );

  final UserProfileRemoteDataSource _remote;
  final UserDeviceLocalDataSource _local;
  final UserProfileLocalDataSource _profileLocal;

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
        UserProfileRemoteDto(userId: accountId, email: email),
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
