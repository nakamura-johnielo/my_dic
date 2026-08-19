import 'model/profile.dart';

/// UserProfile 所有の読み取り専用機能です。
abstract interface class UserProfileQueryPort {
  Stream<AppUser?> watchProfile(String accountId);
}
