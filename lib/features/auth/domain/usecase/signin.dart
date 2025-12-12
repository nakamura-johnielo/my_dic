import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';

class SignInInteractor {
  final IAuthRepository _authRepository;
  SignInInteractor(this._authRepository);
  Future<AppAuth> execute(String email, String password) async {
    return await _authRepository.signInWithEmailAndPassword(
        email: email, password: password);
  }
}
