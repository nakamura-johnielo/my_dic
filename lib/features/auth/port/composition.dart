import 'package:my_dic/features/auth/internal/composition/auth_composition_factory.dart';

import 'composition_contract.dart';

export 'composition_contract.dart';

/// Application-owned runtime dependencies required by Auth.
final class AuthDependencies {
  const AuthDependencies({required this.runtimeGateway});

  final AuthRuntimeGateway runtimeGateway;
}

/// Builds Auth's completed capabilities from explicit typed dependencies.
AuthPorts createAuthPorts({required AuthDependencies dependencies}) =>
    createInternalAuthPorts(runtimeGateway: dependencies.runtimeGateway);
