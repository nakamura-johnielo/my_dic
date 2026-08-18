import 'package:my_dic/features/auth/port/auth.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

/// Router/UI-facing session state derived from `AuthLifecycleState`.
///
/// This is a read-only projection, not a new mutable store: nothing writes
/// to it directly, it is recomputed from `authLifecycleProvider`.
sealed class AppSession {
  const AppSession();

  /// The signed-in account ID, or `null` unless the session is [AppSessionReady].
  String? get accountIdOrNull => null;
}

class AppSessionInitializing extends AppSession {
  const AppSessionInitializing();
}

class AppSessionSignedOut extends AppSession {
  const AppSessionSignedOut();
}

class AppSessionEmailUnverified extends AppSession {
  const AppSessionEmailUnverified(this.identity);

  final AuthIdentity identity;
}

class AppSessionLoadingProfile extends AppSession {
  const AppSessionLoadingProfile(this.identity);

  final AuthIdentity identity;
}

class AppSessionReady extends AppSession {
  const AppSessionReady(this.identity, this.profile);

  final AuthIdentity identity;
  final AppUser profile;

  @override
  String? get accountIdOrNull => identity.accountId;
}

class AppSessionFailure extends AppSession {
  const AppSessionFailure(this.error, {this.identity});

  final AppError error;
  final AuthIdentity? identity;
}
