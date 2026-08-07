import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/features/auth/application/usecase/auth_usecases.dart';
import 'package:my_dic/features/auth/application/usecase/i_sign_in_use_case.dart';

class AppAuthCoordinator {
  final Ref ref;

  final IObserveAuthStateUseCase _observeAuthStateUseCase;
  final IResetEmailPasswordUseCase _resetEmailPasswordUseCase;
  final ISignInUseCase _signInUseCase;
  final ISignUpUseCase _signUpUseCase;
  final ISignOutUseCase _signOutUseCase;
  final IVerifyEmailUseCase _verifyEmailUseCase;

  AppAuthCoordinator(
      this.ref,
      this._observeAuthStateUseCase,
      this._resetEmailPasswordUseCase,
      this._signInUseCase,
      this._signUpUseCase,
      this._signOutUseCase,
      this._verifyEmailUseCase);

  Stream<AppAuth?> observeAuthState() => _observeAuthStateUseCase.execute();

  Future<Result<void>> signOut() async {
    return _signOutUseCase.execute();
  }

  Future<Result<void>> verifyEmail() async {
    final result = await _verifyEmailUseCase.execute();
    return result;
  }

  Future<Result<void>> resetEmailPassword(String email) async {
    final result = await _resetEmailPasswordUseCase.execute(email);
    return result;
  }

  Future<Result<AppAuth>> signIn(String email, String password) async {
    final result = await _signInUseCase.execute(email, password);

    return result.when(
      success: (appAuth) async {
        AppLogger.event('auth.sign_in.succeeded');
        return Result.success(appAuth);
      },
      failure: Result.failure,
    );
  }

  Future<Result<AppAuth>> signUp(String email, String password) async {
    return _signUpUseCase.execute(email, password);
  }
}
