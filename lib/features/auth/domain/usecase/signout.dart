import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/domain/usecase/i_sign_out_use_case.dart';

class SignOutInteractor implements ISignOutUseCase {
  final IAuthRepository _authRepository;
  SignOutInteractor(this._authRepository);

  @override
  Future<Result<void>> execute() async {
    return await _authRepository.signOut();
  }
}
