import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/domain/usecase/i_verify_email_use_case.dart';

class VerifyEmailInteractor implements IVerifyEmailUseCase {
  final IAuthRepository _authRepository;
  VerifyEmailInteractor(this._authRepository);

  @override
  Future<Result<void>> execute() async {
    return await _authRepository.sendEmailVerification();
  }
}
