import 'package:my_dic/features/auth/port/auth.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

/// `AuthLifecycleState` から導出される、ルーター/UI向けのセッション状態。
///
/// これは新しい可変ストアではなく読み取り専用の投影です。直接書き込まれることはなく、
/// `authLifecycleProvider` から再計算されます。
sealed class AppSession {
  const AppSession();

  /// サインイン済みのアカウントID。セッションが [AppSessionReady] 以外の場合は `null`。
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
