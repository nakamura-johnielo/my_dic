import 'package:my_dic/_Business_Rule/_Domain/Entities/user/app_auth.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_auth_repository.dart';

class SignInInteractor {
  final IAuthRepository _authRepository;
  SignInInteractor(this._authRepository);
  Future<AppAuth> execute(String email, String password) async {
    return await _authRepository.signInWithEmailAndPassword(
        email: email, password: password);
  }
}
