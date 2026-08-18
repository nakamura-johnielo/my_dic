import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/session_composition.dart';
import 'package:my_dic/app/bootstrap/feature_composition/user_profile_composition.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/features/user_profile/port/presentation_entry.dart';

UserProfilePresentationSession _userProfilePresentationSession(WidgetRef ref) {
  final session = ref.watch(appSessionProvider);
  final scope = ref.watch(sessionScopeKeyProvider);
  return switch (session) {
    AppSessionReady(:final identity, :final profile)
        when scope != null && scope.accountScope == identity.accountId =>
      UserProfilePresentationSession(
        scope: scope,
        profile: profile,
        accountId: identity.accountId,
        email: identity.email,
      ),
    AppSessionLoadingProfile() =>
      const UserProfilePresentationSession(scope: null, isLoading: true),
    AppSessionFailure(:final error) =>
      UserProfilePresentationSession(scope: null, error: error),
    _ => const UserProfilePresentationSession(scope: null),
  };
}

/// App-owned adapter that supplies UserProfile's controlled Flutter entry.
class UserProfileLifecyclePresentationPage extends ConsumerWidget {
  const UserProfileLifecyclePresentationPage({
    super.key,
    required this.onSignOut,
  });

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      UserProfilePresentationPage(
        session: _userProfilePresentationSession(ref),
        updateUserProfile: ref.watch(userProfilePortsProvider).commands,
        onSignOut: onSignOut,
      );
}
