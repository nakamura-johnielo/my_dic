import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

/// Framework-free profile provisioning capability used after Auth is ready.
abstract interface class EnsureUserProfilePort {
  Future<Result<AppUser>> ensureUserProfile(String accountId, {String? email});
}
