import 'package:my_dic/features/auth/internal/composition/auth_lifecycle_ports_factory.dart';

import 'auth_commands.dart';
import 'auth_readers.dart';

/// Public, framework-free dependency bundle for the app session workflow.
final class AuthLifecyclePorts {
  const AuthLifecyclePorts({
    required this.observeAuthState,
    required this.reloadCurrentAuth,
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.sendVerificationEmail,
  });

  final ObserveAuthStatePort observeAuthState;
  final ReloadCurrentAuthPort reloadCurrentAuth;
  final SignInPort signIn;
  final SignUpPort signUp;
  final SignOutPort signOut;
  final SendVerificationEmailPort sendVerificationEmail;
}

/// Creates Auth's production lifecycle capabilities.
///
/// Framework and SDK construction remains inside the owner implementation;
/// this public signature is deliberately plain Dart.
AuthLifecyclePorts createAuthLifecyclePorts() =>
    createInternalAuthLifecyclePorts();
