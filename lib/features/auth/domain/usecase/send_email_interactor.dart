import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/domain/usecase/i_send_email_use_case.dart';


class ResetEmailPasswordInteractor implements IResetEmailPasswordUseCase {
  final IAuthRepository _authRepository;
  ResetEmailPasswordInteractor(this._authRepository);

  @override
  Future<Result<void>> execute(String email) async {
    return await _authRepository.sendPasswordResetEmail(email: email);
  }
}