import 'package:flutter/material.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/user_profile/internal/presentation/view/profile.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

/// UserProfile の Flutter エントリが描画する、アプリ所有のセッション投影です。
final class UserProfilePresentationSession {
  const UserProfilePresentationSession({
    required this.scope,
    this.profile,
    this.accountId,
    this.email,
    this.error,
    this.isLoading = false,
  });

  final SessionScopeKey? scope;
  final AppUser? profile;
  final String? accountId;
  final String? email;
  final AppError? error;
  final bool isLoading;
}

/// 制御された Flutter エントリです。アプリがセッション状態とコールバックを提供します。
/// Provider と Override 型は意図的にこの公開 API の外に置かれます。
class UserProfilePresentationPage extends StatelessWidget {
  const UserProfilePresentationPage({
    super.key,
    required this.session,
    required this.updateUserProfile,
    required this.onSignOut,
  });

  final UserProfilePresentationSession session;
  final UserProfileCommandPort updateUserProfile;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) => ProfilePage(
        scope: session.scope,
        profile: session.profile,
        accountId: session.accountId,
        email: session.email,
        error: session.error,
        isLoading: session.isLoading,
        updateUserProfile: updateUserProfile,
        onSignOut: onSignOut,
      );
}
