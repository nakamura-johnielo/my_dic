import 'package:my_dic/features/user_profile/port/user_profile.dart';

/// ライフサイクルのプロビジョニングではリモートアダプターを使用できます。通常の
/// プロフィールアクセスは意図的に [UserProfileRepository] の背後でローカル優先に保ちます。
abstract interface class UserProfileProvisioningPort {
  Future<Result<AppUser>> ensureUserProfile({
    required String accountId,
    String? email,
  });
}
