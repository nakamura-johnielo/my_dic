import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/firebase_providers.dart';
import 'package:my_dic/features/auth/port/auth.dart';
import 'package:my_dic/features/auth/port/composition.dart';

/// App-owned lifetime for Auth's completed capabilities.
final authPortsProvider = Provider<AuthPorts>(
  (ref) => createAuthPorts(
    dependencies: AuthDependencies(
      runtimeGateway: ref.watch(firebaseAuthRuntimeProvider),
    ),
  ),
);

final authQueryPortProvider = Provider<AuthQueryPort>(
  (ref) => ref.watch(authPortsProvider).query,
);

final authCommandPortProvider = Provider<AuthCommandPort>(
  (ref) => ref.watch(authPortsProvider).commands,
);
