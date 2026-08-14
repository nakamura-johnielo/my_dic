import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/feature_composition/auth_composition.dart';
import 'package:my_dic/app/bootstrap/feature_composition/user_profile_composition.dart';
import 'auth_lifecycle_controller.dart';
import 'auth_lifecycle_state.dart';

final authLifecycleProvider =
    StateNotifierProvider<AuthLifecycleController, AuthLifecycleState>((ref) {
  return AuthLifecycleController(
    query: ref.watch(authQueryPortProvider),
    commands: ref.watch(authCommandPortProvider),
    userProfileCommands: ref.watch(userProfilePortsProvider).commands,
  );
});
