import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/app/bootstrap/feature_composition/user_profile_composition.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/auth_lifecycle_provider.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/auth_lifecycle_state.dart';

/// `authLifecycleProvider` から導出される、唯一のルーター/UI向けセッション状態。
/// 「利用可能なセッションがあるか」の入口として、ほかを扱ってはいけません。
final appSessionProvider = Provider<AppSession>((ref) {
  final lifecycle = ref.watch(authLifecycleProvider);
  final baseSession = _toAppSession(lifecycle);
  if (baseSession is! AppSessionReady) return baseSession;

  final liveProfile = ref.watch(_liveUserProfileProvider(
    baseSession.identity.accountId,
  ));
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

/// 機能がAuth Repositoryの代わりに依存するaccountId解決ポート。完全に
/// [AppSessionReady] のセッションだけがaccountIdを提供します。メール未確認または
/// プロフィール読み込み中のセッションは、未確認ユーザーが同期やリモート書き込みを行えない
/// という意図に合わせ、accountIdの用途ではゲストとして扱います。
final currentSessionProvider = Provider<CurrentSession>((ref) {
  final session = ref.watch(appSessionProvider);
  return _AppSessionCurrentSession(session);
});

final _liveUserProfileProvider = StreamProvider.autoDispose.family(
    (ref, String accountId) =>
        ref.watch(userProfilePortsProvider).query.watchProfile(accountId));

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
