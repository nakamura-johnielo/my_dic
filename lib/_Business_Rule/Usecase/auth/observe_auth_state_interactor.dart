import 'package:my_dic/_Business_Rule/_Domain/Entities/user/app_auth.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/user/user.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_auth_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_user_repository.dart';
import 'package:my_dic/_Framework_Driver/remote/firebase/Entity/authEntity.dart';

class ObserveAuthStateInteractor {
  final IAuthRepository _repo;
  final IUserRepository _userRepository;
  ObserveAuthStateInteractor(this._repo, this._userRepository);

  Stream<AppAuth?> execute() {
    final authStateStream = _repo.observeAuthState();
    return authStateStream;
  }
}
