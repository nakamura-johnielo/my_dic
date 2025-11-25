import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_auth_repository.dart';

class VerficateInteractor {
  final IAuthRepository _authRepository;
  VerficateInteractor(this._authRepository);
  Future<void> execute() async {
    await _authRepository.sendEmailVerification();
  }
}
