import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/port/composition.dart';
import 'package:my_dic/features/user_profile/port/composition.dart';
import 'auth_lifecycle_controller.dart';
import 'auth_lifecycle_state.dart';

final authLifecycleProvider =
    StateNotifierProvider<AuthLifecycleController, AuthLifecycleState>((ref) {
  return AuthLifecycleController(
    auth: ref.watch(authLifecyclePortsProvider),
    user: ref.watch(userLifecyclePortsProvider),
  );
});
