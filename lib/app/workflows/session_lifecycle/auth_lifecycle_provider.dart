import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/port/composition.dart';
import 'package:my_dic/features/user_profile/port/composition.dart';
import 'auth_lifecycle_controller.dart';
import 'auth_lifecycle_state.dart';
import 'user_profile_composition.dart';

final authLifecycleProvider =
    StateNotifierProvider<AuthLifecycleController, AuthLifecycleState>((ref) {
  return AuthLifecycleController(
    auth: ref.watch(authLifecyclePortsProvider),
    user: UserLifecyclePorts(
      ensureUserProfile: ref.watch(userProfilePortsProvider).ensureUserProfile,
    ),
  );
});

/// App-owned Riverpod lifetime for Auth's pure public composition.
final authLifecyclePortsProvider = Provider<AuthLifecyclePorts>(
  (_) => createAuthLifecyclePorts(),
);
