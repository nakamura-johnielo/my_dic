import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';

class SignUpInteractor {
  final IAuthRepository _authRepository;
  SignUpInteractor(this._authRepository);
  Future<AppAuth> execute(String email, String password) async {
    final authEntity = await _authRepository.createUserWithEmailAndPassword(
        email: email, password: password);
    return authEntity;
  }
}
