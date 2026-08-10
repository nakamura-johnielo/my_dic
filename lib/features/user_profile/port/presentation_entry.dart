import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

export 'package:my_dic/features/user_profile/internal/presentation/view/profile.dart'
    show ProfilePage;

/// App-supplied session input for the User presentation entry.
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

final userProfilePresentationSessionProvider =
    Provider<UserProfilePresentationSession>((ref) {
  throw UnsupportedError('User profile presentation entry is not installed.');
});
