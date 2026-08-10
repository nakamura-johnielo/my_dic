import 'package:my_dic/features/user_profile/port/user_profile.dart';

/// Read-only local profile projection used by the app-owned session workflow.
abstract interface class LiveUserProfilePort {
  Stream<AppUser?> watchProfile(String accountId);
}
