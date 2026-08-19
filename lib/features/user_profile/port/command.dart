import 'package:my_dic/core/shared/utils/result.dart';

import 'model/profile.dart';

/// UserProfile 所有の状態変更機能です。
///
/// 空のアカウント ID は、コントラクト移行後も既存のセッション／プロフィール動作を
/// 変えないよう、意図的に実行時エラーのままとします。
abstract interface class UserProfileCommandPort {
  Future<Result<AppUser>> ensureUserProfile(
    String accountId, {
    String? email,
  });

  Future<Result<void>> updateUser(AppUser user, String accountId);
}
