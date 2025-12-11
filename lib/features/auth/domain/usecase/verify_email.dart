import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';

class VerifyEmailInteractor {
  final IAuthRepository _authRepository;
  VerifyEmailInteractor(this._authRepository);
  Future<void> execute() async {
    await _authRepository.sendEmailVerification();
  }
}
