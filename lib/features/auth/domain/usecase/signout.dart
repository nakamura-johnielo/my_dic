import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';

class SignOutInteractor {
  final IAuthRepository _authRepository;
  SignOutInteractor(this._authRepository);

  Future<Result<void>> execute() async {
    return await _authRepository.signOut();
  }
}
