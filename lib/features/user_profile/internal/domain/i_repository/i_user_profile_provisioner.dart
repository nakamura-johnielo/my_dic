import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

/// Lifecycle provisioning can use a remote adapter. Normal profile access is
/// intentionally kept behind [IUserRepository] and local-first.
abstract interface class IUserProfileProvisioner {
  Future<Result<AppUser>> ensureUserProfile({
    required String accountId,
    String? email,
  });
}
