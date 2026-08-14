import 'package:my_dic/core/shared/utils/result.dart';

import 'model/profile.dart';

/// UserProfile-owned state-changing capabilities.
///
/// Empty account IDs deliberately remain execution-time failures so the
/// existing session/profile behavior is unchanged by the contract migration.
abstract interface class UserProfileCommandPort {
  Future<Result<AppUser>> ensureUserProfile(
    String accountId, {
    String? email,
  });

  Future<Result<void>> updateUser(AppUser user, String accountId);
}
