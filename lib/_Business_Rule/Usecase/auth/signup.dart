import 'package:my_dic/_Business_Rule/_Domain/Entities/user/app_auth.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_auth_repository.dart';

class SignUpInteractor {
  final IAuthRepository _authRepository;
  SignUpInteractor(this._authRepository);
  Future<AppAuth> execute(String email, String password) async {
    final authEntity = await _authRepository.createUserWithEmailAndPassword(
        email: email, password: password);
    return authEntity;
  }
}

class SignOutInteractor {
  final IAuthRepository _authRepository;
  SignOutInteractor(this._authRepository);
  Future<void> execute() async {
    await _authRepository.signOut();
  }
}
