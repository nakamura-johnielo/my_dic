import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';

class VerifyEmailInteractor {
  final IAuthRepository _authRepository;
  VerifyEmailInteractor(this._authRepository);

  Future<Result<void>> execute() async {
    return await _authRepository.sendEmailVerification();
  }
}
