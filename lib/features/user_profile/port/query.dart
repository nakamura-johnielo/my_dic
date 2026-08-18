import 'model/profile.dart';

/// UserProfile-owned read-only capabilities.
abstract interface class UserProfileQueryPort {
  Stream<AppUser?> watchProfile(String accountId);
}
