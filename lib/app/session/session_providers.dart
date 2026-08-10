import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/app/workflows/session_lifecycle/auth_lifecycle_provider.dart';
import 'package:my_dic/app/workflows/session_lifecycle/auth_lifecycle_state.dart';
import 'package:my_dic/features/user_profile/port/composition.dart';

/// The single Router/UI-facing session state, derived from
/// `authLifecycleProvider`. Nothing else should be treated as the entry
/// point for "is there a usable session".
final appSessionProvider = Provider<AppSession>((ref) {
  final lifecycle = ref.watch(authLifecycleProvider);
  final baseSession = _toAppSession(lifecycle);
  if (baseSession is! AppSessionReady) return baseSession;

  final liveProfile =
      ref.watch(liveUserProfileProvider(baseSession.identity.accountId));
  return liveProfile.when(
    loading: () => AppSessionLoadingProfile(baseSession.identity),
    error: (error, stackTrace) => AppSessionFailure(
      UnexpectedError(
        message: 'Local profile stream failed',
        originalError: error,
        stackTrace: stackTrace,
      ),
      identity: baseSession.identity,
    ),
    data: (profile) => profile == null
        ? AppSessionLoadingProfile(baseSession.identity)
        : AppSessionReady(
            baseSession.identity,
            baseSession.profile.copyWith(username: profile.username),
          ),
  );
});

/// The accountId resolution port features depend on instead of Auth
/// Repository. Only a fully [AppSessionReady] session yields an accountId;
/// email-unverified or profile-loading sessions are treated as guest for
/// accountId purposes, matching the intent that unverified users must not
/// reach sync or remote writes.
final currentSessionProvider = Provider<CurrentSession>((ref) {
  final session = ref.watch(appSessionProvider);
  return _AppSessionCurrentSession(session);
});

AppSession _toAppSession(AuthLifecycleState state) {
  final auth = state.auth;
  switch (state.phase) {
    case AuthLifecyclePhase.initializing:
      return const AppSessionInitializing();
    case AuthLifecyclePhase.signedOut:
    case AuthLifecyclePhase.creatingAccount:
    case AuthLifecyclePhase.signingIn:
    case AuthLifecyclePhase.signingOut:
      return const AppSessionSignedOut();
    case AuthLifecyclePhase.sendingVerificationEmail:
    case AuthLifecyclePhase.emailUnverified:
    case AuthLifecyclePhase.verificationEmailFailed:
    case AuthLifecyclePhase.reloadingIdentity:
      return auth == null
          ? const AppSessionSignedOut()
          : AppSessionEmailUnverified(auth);
    case AuthLifecyclePhase.provisioningProfile:
      return auth == null
          ? const AppSessionSignedOut()
          : AppSessionLoadingProfile(auth);
    case AuthLifecyclePhase.profileProvisioningFailed:
      return AppSessionFailure(
        state.error ??
            const UnexpectedError(message: 'Profile provisioning failed'),
        identity: auth,
      );
    case AuthLifecyclePhase.ready:
      final user = state.user;
      if (auth == null || user == null) {
        return const AppSessionSignedOut();
      }
      return AppSessionReady(auth, user);
  }
}

class _AppSessionCurrentSession implements CurrentSession {
  const _AppSessionCurrentSession(this._session);

  final AppSession _session;

  @override
  String? get accountIdOrNull => _session.accountIdOrNull;

  @override
  String requireAccountId() {
    final id = accountIdOrNull;
    if (id == null) throw SessionRequiresAccountError();
    return id;
  }
}
