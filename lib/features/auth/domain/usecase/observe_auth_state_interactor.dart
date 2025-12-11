import 'package:my_dic/features/auth/domain/entity/auth.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';

class ObserveAuthStateInteractor {
  final IAuthRepository _repo;
  ObserveAuthStateInteractor(this._repo);

  Stream<AppAuth?> execute() {
    final authStateStream = _repo.observeAuthState();
    return authStateStream;
  }
}
