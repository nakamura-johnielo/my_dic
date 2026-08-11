import 'package:my_dic/features/auth/internal/application/usecase/auth_usecases.dart';
import 'package:my_dic/features/auth/internal/application/usecase/signin.dart';
import 'package:my_dic/features/auth/internal/domain/repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/internal/infrastructure/firebase/firebase_auth_production_repository.dart';
import 'package:my_dic/features/auth/port/composition.dart';

/// Owner-only assembly of public lifecycle capabilities.
///
/// SDK construction stays in the canonical Firebase infrastructure adapter.
AuthLifecyclePorts createInternalAuthLifecyclePorts() =>
    _createPorts(createFirebaseAuthRepository());

AuthLifecyclePorts _createPorts(IAuthRepository repository) =>
    AuthLifecyclePorts(
      observeAuthState: ObserveAuthStateInteractor(repository),
      reloadCurrentAuth: ReloadCurrentAuthInteractor(repository),
      signIn: SignInInteractor(repository),
      signUp: SignUpInteractor(repository),
      signOut: SignOutInteractor(repository),
      sendVerificationEmail: VerifyEmailInteractor(repository),
    );
