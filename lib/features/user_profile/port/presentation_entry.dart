import 'package:flutter/material.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/features/user_profile/internal/presentation/view/profile.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

/// App-owned session projection rendered by UserProfile's Flutter entry.
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

/// Controlled Flutter entry. The app supplies session state and callbacks;
/// Provider and Override types deliberately remain outside this public API.
class UserProfilePresentationPage extends StatelessWidget {
  const UserProfilePresentationPage({
    super.key,
    required this.session,
    required this.updateUserProfile,
    required this.onSignOut,
  });

  final UserProfilePresentationSession session;
  final UpdateUserProfilePort updateUserProfile;
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
