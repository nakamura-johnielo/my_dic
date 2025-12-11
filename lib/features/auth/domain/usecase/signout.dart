import 'package:my_dic/features/auth/domain/entity/auth.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';

class SignOutInteractor {
  final IAuthRepository _authRepository;
  SignOutInteractor(this._authRepository);
  Future<void> execute() async {
    await _authRepository.signOut();
  }
}
