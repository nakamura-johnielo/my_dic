import 'package:my_dic/features/user_profile/internal/domain/repository/user_profile_repository.dart';
import 'package:my_dic/features/user_profile/internal/domain/service/user_profile_provisioning_port.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

/// UserProfile の完成済み状態変更アプリケーション機能です。
final class UserProfileApplicationService implements UserProfileCommandPort {
  UserProfileApplicationService({
    required UserProfileProvisioningPort provisioning,
    required IUserProfileRepository repository,
  })  : _provisioning = provisioning,
        _repository = repository;

  final UserProfileProvisioningPort _provisioning;
  final IUserProfileRepository _repository;

  @override
  Future<Result<AppUser>> ensureUserProfile(
    String accountId, {
    String? email,
  }) =>
      _provisioning.ensureUserProfile(accountId: accountId, email: email);

  @override
  Future<Result<void>> updateUser(AppUser user, String accountId) =>
      _repository.updateUser(user, accountId);
}
